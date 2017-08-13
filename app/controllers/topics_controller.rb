class TopicsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin_and_agent
  before_action :authenticate_user!, :only => ['tickets','ticket']
  before_action :allow_iframe_requests
  before_action :forums_enabled?, only: ['index','show']
  before_action :topic_creation_enabled?, only: ['new', 'create']
  before_action :get_all_teams, only: 'new'
  before_action :get_public_forums, only: ['new', 'create']
  # theme :theme_chosen


  def index
    GeneralHelpers.params_validation(:get, :topic_index, params)
    @forum = Forum.ispublic.where(id: params[:forum_id]).first
    if @forum
      if @forum.allow_topic_voting == true
        @topics = @forum.topics.ispublic.by_popularity.page params[:page]
      else
        @topics = @forum.topics.ispublic.chronologic.page params[:page]
      end
      @page_title = @forum.name
      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          topic: @topic,
          page_title: @page_title,
          forum: @forum
        }
      }
    else
      redirect_path({root_path: root_path}) && return
    end
  end

  def tickets
    GeneralHelpers.params_validation(:get, :tickets, params)
    @topics = current_user.topics.isprivate.undeleted.chronologic.page params[:page]
    @page_title = 'Tickets'
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        topics: @topics,
        page_title: @page_title
      }
    }
  end

  def ticket
    @topic = current_user.topics.undeleted.where(id: params[:id]).first
    if @topic
      @posts = @topic.posts.ispublic.chronologic.active.all.includes(:topic, :user, :screenshot_files)
      @page_title = "##{@topic.id} #{@topic.name}"
      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          posts: @posts,
          page_title: @page_title,
          topic: @topic
        }
      }
    else
      redirect_path({root_path: root_path}) && return
    end
  end

  def new
    @page_title = "Mở một ticket"
    @topic = Topic.new
    @user = @topic.build_user unless user_signed_in?
    @topic.posts.build

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        page_title: @page_title,
        topic: @topic,
        user: @user
      }
    }
  end

  def create
    GeneralHelpers.params_validation(:create, :create_topic, params)
    params[:id].nil? ? @forum = Forum.find_by_id(params[:topic][:forum_id]) : @forum = Forum.find_by_id(params[:id])

    @topic = @forum.topics.new(
      name: params[:topic][:name],
      private: params[:topic][:private],
      doc_id: params[:topic][:doc_id],
      team_list: params[:topic][:team_list],
      channel: 'web')

    if recaptcha_enabled?
      unless verify_recaptcha(model: @topic)
        redirect_path({new_topic_path: new_topic_path}) && return
      end
    end

    if @topic.create_topic_with_user(params, current_user)
      @user = @topic.user
      @post = @topic.posts.create(
        :body => params[:topic][:posts_attributes]["0"][:body],
        :user_id => @user.id,
        :kind => 'first',
        :screenshots => params[:topic][:screenshots],
        :attachments => params[:topic][:posts_attributes]["0"][:attachments])

      if !user_signed_in?
        # UserMailer.new_user(@user.id, @user.reset_password_token).deliver_later
      end

      # track event in GA
      tracker('Request', 'Post', 'New Topic')
      tracker('Agent: Unassigned', 'New', @topic.to_param)

      if @topic.private?
        redirect_path({topic_thanks_path: topic_thanks_path}) && return
      else
        redirect_path({topic_posts_path: topic_posts_path(@topic)}) && return
      end
    else
      redirect_path({new_topic_path: new_topic_path}) && return
    end
  end

  def thanks
    @page_title = "Cảm ơn bạn"
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        page_title: @page_title
      }
    }
  end

  def up_vote
    GeneralHelpers.params_validation(:create, :up_vote, params)
    if user_signed_in?
      @forum = nil
      @topic = Topic.find_by(id: params[:id])
      if @topic
        @forum = @topic.forum
        @topic.votes.create(user_id: current_user.id)
        @topic.touch
        @topic.reload
      end
    end
    # respond_to do |format|
    #   format.js
    # end
  end

  def tag
    @topics = Topic.ispublic.tag_counts_on(:tags)
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        topics: @topics
      }
    }
  end

  private

  def post_params
    params.require(:post).permit(
      :body,
      :kind,
      {attachments: []}
    )
  end

  def get_public_forums
    @forums = Forum.ispublic.all
  end

end
