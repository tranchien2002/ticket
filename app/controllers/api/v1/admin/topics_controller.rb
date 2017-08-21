class Api::V1::Admin::TopicsController < Api::V1::Admin::BaseController
  before_action :fetch_counts, only: ['index','show', 'update_topic', 'user_profile']
  before_action :remote_search, only: ['index', 'show', 'update_topic']
  before_action :get_all_teams, except: ['shortcuts']

  def index
    @status = params[:status] || "pending"
    if current_user.is_restricted? && teams?
      topics_raw = Topic.all.tagged_with(current_user.team_list, any: true)
    else
      topics_raw = params[:team].present? ? Topic.all.tagged_with(params[:team], any: true) : Topic
    end
    topics_raw = topics_raw.select("users.name as user_name", "users.email as user_email", "topics.*",
      "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
      .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
      .order(updated_at: :desc)
    get_all_teams
    case @status
    when 'all'
      topics_raw = topics_raw.all
    when 'new'
      topics_raw = topics_raw.unread
    when 'active'
      topics_raw = topics_raw.active
    when 'unread'
      topics_raw = topics_raw.unread.all
    when 'assigned'
      topics_raw = topics_raw.mine(current_user.id)
    when 'pending'
      topics_raw = topics_raw.pending.mine(current_user.id)
    else
      topics_raw = topics_raw.where(current_status: @status)
    end
    @topics = topics_raw.paginate(page: params[:page], per_page: Settings.per_page)
    tracker("Admin-Nav", "Click", @status.titleize)
  end

  def show
    GeneralHelpers.params_validation(:get, :admin_show_topic, params)
    @topic = Topic.where(id: params[:id]).first

    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy topic"
      }
    ) unless @topic

    # REVIEW: Try not opening message on view unless assigned
    check_current_user_is_allowed? @topic
    if @topic.current_status == 'new' && @topic.assigned?
      tracker("Agent: #{current_user.name}", "Opened Ticket", @topic.to_param, @topic.id)
      @topic.open
    end
    get_all_teams
    @posts = @topic.posts.chronologic.includes(:user)
    tracker("Agent: #{current_user.name}", "Viewed Ticket", @topic.to_param, @topic.id)
    fetch_counts

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        topic: @topic,
        posts: @posts
      }
    }
  end

  def create
    params[:admin_create_topic] = JSON.parse(params[:admin_create_topic])
    GeneralHelpers.params_validation(:create, :admin_create_topic, params)
    topic = Topic.create(
      name: params[:admin_create_topic][:topic][:name],
      tag_list: params[:admin_create_topic][:topic][:tag_list],
      user_id: current_user.id
    )
    post = topic.posts.new(
      body: params[:admin_create_topic][:post][:body],
      user_id: current_user.id,
      kind: :first,
      attachments: params[:admin_create_topic][:post][:attachments]
    )
    if post.save
      attachments = params[:attachments]
      if attachments.present?
        dir = "#{Rails.root}/public/attachment/posts/#{post.id}/"
        post.update_columns attachments: save_files_with_token(dir, attachments).to_json
      end
    end
    render json: {code: 1, message: "Thành công"}
  end

  # Updates discussion status
  def update_topic
    GeneralHelpers.params_validation(:update, :admin_update_topic, params)
    logger.info("Starting update")

    #handle array of topics
    @topics = Topic.where(id: params[:topic_ids])

    bulk_post_attributes = []

    if params[:change_status].present?

      if ["closed", "reopen", "trash"].include?(params[:change_status])
        user_id = current_user.id || 2
        @topics.each do |topic|
          # prepare bulk params
          bulk_post_attributes << {body: I18n.t("#{params[:change_status]}_message", user_name: User.find(user_id).name), kind: 'note', user_id: user_id, topic_id: topic.id}
        end

        case params[:change_status]
        when 'closed'
          @topics.bulk_close(bulk_post_attributes)
        when 'reopen'
          @topics.bulk_reopen(bulk_post_attributes)
        when 'trash'
          @topics.bulk_trash(bulk_post_attributes)
        end
      else
        @topics.update_all(current_status: params[:change_status])
      end

      @action_performed = "Marked #{params[:change_status].titleize}"
      # Calls to GA for close, reopen, assigned.
      tracker("Agent: #{current_user.name}", @action_performed, @topics.to_param, 0)

    end

    if params[:topic_ids].present?
      @topic = Topic.find_by_id(params[:topic_ids].last)
      raise APIError::Common::NotFound.new(
        {
          status: 404,
          message: "Không tìm thấy topic"
        }
      ) unless @topic
      @posts = @topic.posts.chronologic
    end

    fetch_counts
    get_all_teams

    if params[:topic_ids].count > 1
      get_tickets
      redirect_path({admin_topics_path: 'admin/topics/index'}) && return
    else
      redirect_path({update_admin_topics_path: 'admin/topics/update_ticket'}, {id: @topic.id}) && return
    end
  end

  # Assigns a discussion to another agent
  def assign_agent
    GeneralHelpers.params_validation(:update, :admin_assign_agent, params)
    assigned_user = User.find_by_id(params[:assigned_user_id])
    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy người dùng"
      }
    )
    @topics = Topic.where(id: params[:topic_ids])
    bulk_post_attributes = []
    unless params[:assigned_user_id].blank?
      #handle array of topics
      @topics.each do |topic|
        # if message was unassigned previously, use the new assignee
        # this is to give note attribution below
        previous_assigned_id = topic.assigned_user_id || params[:assigned_user_id]
        bulk_post_attributes << {body: I18n.t(:assigned_message, assigned_to: assigned_user.name), kind: 'note', user_id: previous_assigned_id, topic_id: topic.id}

        # Calls to GA
        tracker("Agent: #{current_user.name}", "Assigned to #{assigned_user.name.titleize}", @topic.to_param, 0)
      end
    end

    @topics.bulk_agent_assign(bulk_post_attributes, assigned_user.id) if bulk_post_attributes.present?

    if params[:topic_ids].count > 1
      get_tickets
    else
      @topic = Topic.find_by_id(@topics.first.id)
      raise APIError::Common::NotFound.new(
        {
          status: 404,
          message: "Không tìm thấy topic"
        }
      )
      @posts = @topic.posts.chronologic
    end

    logger.info("Count: #{params[:topic_ids].count}")

    fetch_counts
    get_all_teams

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        redirect_to: {
          path: path =  if params[:topic_ids].count > 1
                          get_tickets
                          admin_topics_path
                        else
                          {update_ticket: 'update_ticket', id: @topic.id}
                        end
        }
      }
    }
  end

  # Toggle privacy of a topic
  def toggle_privacy
    GeneralHelpers.params_validation(:update, :admin_toggle_privacy, params)
    #handle array of topics
    @topics = Topic.where(id: params[:topic_ids])
    @topics.update_all(private: params[:private], forum_id: params[:forum_id])
    bulk_post_attributes = []

    @topics.each do |topic|
      if topic.forum_id == 1
        bulk_post_attributes << {body: I18n.t(:converted_to_ticket), kind: 'note', user_id: current_user.id, topic_id: topic.id}
      else
        bulk_post_attributes << {body: I18n.t(:converted_to_topic, forum_name: topic.forum.name), kind: 'note', user_id: current_user.id, topic_id: topic.id}
      end

      # Calls to GA
      tracker("Agent: #{current_user.name}", "Moved to  #{topic.forum.name}", @topic.to_param, 0)
    end

    # Bulk insert notes
    Post.bulk_insert values: bulk_post_attributes

    @topic = @topics.last
    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy topic"
      }
    )
    @posts = @topic.posts.chronologic

    fetch_counts
    get_all_teams

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        redirect_to: {
          path: path =  if params[:topic_ids].count > 1
                          # get_tickets
                          admin_topics_path
                        else
                          {update_ticket: 'update_ticket', id: @topic.id}
                        end
        }
      }
    }
  end

  def update
    @topic = Topic.find(params[:id])

    if @topic.update_attributes(topic_params)
      # respond_to do |format|
      #   format.html {
          redirect_path({admin_topics_path:admin_topics_path(@topic)}) && return
        # }
        # format.json {
          # respond_with_bip(@topic)
        # }
      # end
    else
      logger.info("error")
    end
  end

  def update_tags
    @topic = Topic.find(params[:id])

    if @topic.update_attributes(topic_params)
      @posts = @topic.posts.chronologic

      fetch_counts
      get_all_teams


      @topic.posts.create(
        body: t('tagged_with', topic_id: @topic.id, tagged_with: @topic.tag_list),
        user: current_user,
        kind: 'note',
      )

      # respond_to do |format|
      #   format.html {
          redirect_path({admin_topics_path: admin_topics_path(@topic)}) && return
        # }
        # format.js {
          render 'update_ticket', id: @topic.id
        # }
      # end
    else
      logger.info("error")
    end
  end

  def assign_team
    assigned_group = params[:team]
    @topics = Topic.where(id: params[:topic_ids])
    bulk_post_attributes = []
    unless assigned_group.blank?
      #handle array of topics
      @topics.each do |topic|
        bulk_post_attributes << {body: I18n.t(:assigned_group, assigned_group: assigned_group), kind: 'note', user_id: current_user.id, topic_id: topic.id}

        # Calls to GA
        tracker("Agent: #{current_user.name}", "Assigned to #{assigned_group.titleize}", @topic.to_param, 0)
      end
    end

    @topics.bulk_group_assign(bulk_post_attributes, assigned_group) if bulk_post_attributes.present?

    if params[:topic_ids].count > 1
      get_tickets
    else
      @topic = Topic.find(@topics.first.id)
      @posts = @topic.posts.chronologic
    end

    fetch_counts
    get_all_teams
    # respond_to do |format|
    #   format.html #render action: 'ticket', id: @topic.id
    #   format.js {
        if params[:topic_ids].count > 1
          get_tickets
          render 'index'
        else
          render 'update_ticket', id: @topic.id
        end
      # }
    # end
  end

  def unassign_team
    GeneralHelpers.params_validation(:get, :admin_unassign_team, params)
    @topic = Topic.where(id: params[:topic_ids]).first

    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy dữ liệu"
      }
    ) unless @topic

    @topic.team_list = ""
    @topic.save

    @topic.posts.create(
      body: "This ticket was unassigned from all team groups",
      user: current_user,
      kind: 'note',
    )

    @posts = @topic.posts.chronologic

    fetch_counts
    get_all_teams

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        redirect_to: {
          update_ticket_path: 'update_ticket'
        },
        id: @topic.id
      }
    }
  end

  def split_topic
    GeneralHelpers.params_validation(:create, :admin_split_topic, params)
    parent_topic = Topic.find_by_id(params[:topic_id])
    parent_post = Post.find_by_id(params[:post_id])

    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy dữ liệu"
    ) unless parent_topic || parent_post

    @topic = Topic.new(
      name: t('new_discussion_topic_title', original_name: parent_topic.name, original_id: parent_topic.id, default: "Split from #{parent_topic.id}-#{parent_topic.name}"),
      user: parent_post.user,
      forum_id: parent_topic.forum_id,
      private: parent_topic.private,
      channel: parent_topic.channel,
      kind: parent_topic.kind,
    )

    @posts = @topic.posts

    if @topic.save
      @posts.create(
        body: parent_post.body,
        user: parent_post.user,
        kind: 'first',
        screenshots: parent_post.screenshots,
        attachments: parent_post.attachments,
      )

      parent_topic.posts.create(
        body: t('new_discussion_post', topic_id: @topic.id, default: "Discussion ##{@topic.id} was created from this one"),
        user: current_user,
        kind: 'note',
      )
    end

    fetch_counts
    get_all_teams

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        redirect_to: {
          admin_topic_path: admin_topic_path(@topic),
          update_ticket: {render: 'update_ticket', id: @topic.id}
        }
      }
    }
  end

  def merge_tickets
    GeneralHelpers.params_validation(:create, :admin_merge_tickets, params)
    @topic = Topic.merge_topics(params[:topic_ids], current_user.id)
    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy topic"
    ) unless @topic

    @posts = @topic.posts.chronologic
    fetch_counts
    get_all_teams

    redirect_path({admin_topic_path: admin_topic_path}, {id: @topic}) && return
  end

  def shortcuts
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-plain'
      }
    }
  end

  private
  def get_tickets
    GeneralHelpers.params_validation(:get, :admin_get_tickets, params)
    if params[:status].nil?
      @status = "pending"
    else
      @status = params[:status]
    end

    case @status

    when 'all'
      @topics = Topic.all.page params[:page]
    when 'new'
      @topics = Topic.unread.page params[:page]
    when 'active'
      @topics = Topic.active.page params[:page]
    when 'unread'
      @topics = Topic.unread.all.page params[:page]
    when 'assigned'
      @topics = Topic.mine(current_user.id).page params[:page]
    when 'pending'
      @topics = Topic.pending.mine(current_user.id).page params[:page]
    else
      @topics = Topic.where(current_status: @status).page params[:page]
    end

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        topics: @topics
      }
    }
  end

  def topic_params
    params.require(:topic).permit(:name)
    params.require(:topic).permit(:tag_list)
  end
end
