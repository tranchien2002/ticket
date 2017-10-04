class Api::V1::Admin::TopicsController < Api::V1::Admin::BaseController
  # before_action :fetch_counts, only: ['show', 'user_profile']
  # before_action :remote_search, only: ['index', 'show', 'update_topic']
  # before_action :get_all_teams, except: ['shortcuts']

  def dashboard
    @all = Topic.where(building_id: current_user.building_id).count
    @new = Topic.neww(current_user.building_id).count
    @active = Topic.active(current_user.building_id).count
    @mine = Topic.mine(current_user.building_id, current_user.id).count
    @closed = Topic.closed(current_user.building_id).count
  end

  def index
    @status = params[:status] || "new"
    if @status == "all"
      @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
        "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
        .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
        .where(building_id: current_user.building_id).order(updated_at: :desc)
        .paginate(page: params[:page], per_page: Settings.per_page)
    elsif @status == "mine"
      @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
        "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
        .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
        .where(building_id: current_user.building_id, current_status: Settings.ticket_status.active, assigned_user_id: current_user.id)
        .order(updated_at: :desc)
        .paginate(page: params[:page], per_page: Settings.per_page)
    else
      @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
        "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
        .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
        .where(building_id: current_user.building_id, current_status: @status).order(updated_at: :desc)
        .paginate(page: params[:page], per_page: Settings.per_page)
    end
  end

  def search
    @topics = Topic.select("users.uid as user_uid", "users.name as user_name", "users.email as user_email", "topics.*",
      "assigned_users.uid as assigned_user_uid", "assigned_users.name as assigned_user_name", "assigned_users.email as assigned_user_email")
      .joins(:user).joins("LEFT JOIN users assigned_users ON assigned_users.id = topics.assigned_user_id")
      .search(building_id_eq: current_user.building_id, name_cont: params[:keyword],
        created_at_gteq: params[:created_at], closed_date_lteq: params[:closed_date])
      .result.order(updated_at: :desc)
      .paginate(page: params[:page], per_page: Settings.per_page)
  end

  def show
    @topic = Topic.includes(:user, :assigned_user).find_by(id: params[:id])
    raise APIError::Common::NotFound unless @topic
    @posts = Post.select("users.name as user_name", "users.email as user_email", "posts.*")
      .joins(:user).where(topic_id: @topic.id)
  end

  def create
    params[:admin_create_topic] = JSON.parse(params[:admin_create_topic])
    GeneralHelpers.params_validation(:create, :admin_create_topic, params)

    new_ticket = {
      name: params[:admin_create_topic][:topic][:name],
      user_id: current_user.id,
      building_id: current_user.building_id
    }

    [:begin_date, :deadline].each do |key|
      if params[:admin_create_topic][:topic].has_key?(key) &&
        params[:admin_create_topic][:topic][key].present?
        new_ticket.merge!({"#{key}": params[:admin_create_topic][:topic][key]})
      end
    end

    if params[:admin_create_topic][:topic][:assigned_user].present?
      params_assigned_user = params[:admin_create_topic][:topic][:assigned_user]
      assigned_user = User.find_by(uid: params_assigned_user[:id]) || User.new
      assigned_user.uid = params_assigned_user[:id]
      assigned_user.name = params_assigned_user[:name]
      assigned_user.email = params_assigned_user[:email]
      assigned_user.phone = params_assigned_user[:phone]
      assigned_user.role = params_assigned_user[:type]
      assigned_user.building_id = current_user.building_id
      raise APIError::Common::UnSaved unless assigned_user.save

      new_ticket.merge!(
        {
          assigned_user_id: assigned_user.try(:id),
          current_status: Settings.ticket_status.active
        }
      )
    else
      new_ticket.merge!({current_status: Settings.ticket_status.new})
    end

    topic = Topic.create(new_ticket)

    post = topic.posts.new(
      body: params[:admin_create_topic][:post][:body],
      user_id: current_user.id,
      kind: :first
    )
    if post.save
      attachments = params[:attachments]
      if attachments.present?
        dir = "#{Rails.root}/public/attachments/posts/#{post.id}/"
        post.update_columns attachments: save_files_with_token(dir, attachments).to_json
      end
    end
    render json: {code: 1, message: "Thành công"}
  end

  # Updates discussion status
  def update_topic
    @topics = Topic.where(id: params[:topic_ids])
    raise APIError::Common::NotFound unless @topics.present?
    bulk_post_attributes = []
    if params[:change_status] == "closed"
      @topics.each do |topic|
        bulk_post_attributes << {
          body: "Công việc này đã đóng bởi #{current_user.name}.",
          kind: 'note',
          user_id: current_user.id,
          topic_id: topic.id
        }
      end
      @topics.bulk_close(bulk_post_attributes)
    elsif params[:change_status] == "mine"
      @topics.each do |topic|
        bulk_post_attributes << {
          body: "#{current_user.name} đã nhận công việc này.",
          kind: 'note',
          user_id: current_user.id,
          topic_id: topic.id
        }
      end
      @topics.bulk_agent_assign(bulk_post_attributes, current_user.id)
    elsif params[:change_status] == "new"
      @topics.each do |topic|
        bulk_post_attributes << {
          body: "Công việc này đã mở trở lại bởi #{current_user.name}",
          kind: 'note',
          user_id: current_user.id,
          topic_id: topic.id
        }
      end
      @topics.bulk_reopen(bulk_post_attributes)
    else
      @topics.update_all(current_status: params[:change_status], updated_at: Time.current)
    end
    render json: {code: 1, message: "Thành công"}
  end

  def assign_agent
    raise APIError::Common::BadRequest unless params[:assigned_user].present?
    assigned_user = User.find_by(uid: params[:assigned_user][:id]) || User.new
    assigned_user.uid = params_assigned_user[:id]
    assigned_user.name = params_assigned_user[:name]
    assigned_user.email = params_assigned_user[:email]
    assigned_user.phone = params_assigned_user[:phone]
    assigned_user.role = params_assigned_user[:type]
    assigned_user.building_id = current_user.building_id
    raise APIError::Common::UnSaved unless assigned_user.save

    @topics = Topic.where(id: params[:topic_ids])
    raise APIError::Common::NotFound unless @topics.present?

    bulk_post_attributes = []
    @topics.each do |topic|
      bulk_post_attributes << {
        body: "Công việc này đã được gán cho #{assigned_user.name}",
        kind: 'note',
        user_id: current_user.id,
        topic_id: topic.id
      }
    end
    @topics.bulk_agent_assign(bulk_post_attributes, assigned_user.id) if bulk_post_attributes.present?
    render json: {code: 1, message: "Thành công"}
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
