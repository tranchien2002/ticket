#done
class PostsController < ApplicationController

  # Make sure forums are enabled
  before_action :forums_enabled?, only: ['index','show']
  skip_before_filter :verify_authenticity_token
  before_action :verify_admin_and_agent

  respond_to :js, only: [:up_vote]
  # layout "clean", only: :index
  theme :theme_chosen

  def index
    @topic = Topic.undeleted.ispublic.where(id: params[:topic_id]).first#.includes(:forum)
    if @topic
      @posts = @topic.posts.ispublic.active.all.chronologic.includes(:user)
      @post = @topic.posts.new
      @page_title = "#{@topic.name}"
      render json: {
        code: 1,
        message: "",
        data: {
          posts: @posts,
          post: @post,
          page_title: @page_title
        }
      }
    end

    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy topic"
      }
    )
  end

  def create
    GeneralHelpers.params_validation(:create, :create_post, params)
    @topic = Topic.find_by_id(params[:topic_id])

    raise APIError::Common::BadRequest.new unless @topic

    @post = @topic.posts.new(post_params)
    @post.topic_id = @topic.id
    @post.user_id = current_user.id
    @post.screenshots = params[:post][:screenshots]

    if @post.save
      @posts = @topic.posts.ispublic.chronologic.active
      if @topic.public?
        # This is a forum post
        path = @topic.doc.nil? ? topic_posts_path(@topic.id) : doc_path(@topic.doc_id)

        redirect_path({path: path}, {posts: @posts}) && return
      else
        # This post belongs to a ticket
        agent = User.find(@topic.assigned_user_id)
        tracker("Agent: #{agent.name}", "User Replied", @topic.to_param) #TODO: Need minutes
        redirect_path({ticket_path: ticket_path(@topic.id)}, {posts: @posts}) && return
      return
      end

      @posts = @topic.posts.ispublic.chronologic.active
      render json: {
        code:  Settings.code.success,
        message: "",
        data: {
          posts: @posts
        }
      }
      unless @topic.assigned_user_id.nil?
        agent = User.find_by(id: @topic.assigned_user_id)
        tracker("Agent: #{agent.name}", "User Replied", @topic.to_param) #TODO: Need minutes
      end

    else
      raise APIError::Common::ServerError.new(
        {
          code: Settings.code.failure,
          message: "Đã xảy ra lỗi khi lưu bài đăng"
        }
      )
    end
  end

  def up_vote
    GeneralHelpers.params_validation(:get, :up_vote, params)
    if user_signed_in?
      @post = Post.find_by_id(params[:id])
      raise APIError::Common::BadRequest unless @post
      @post.votes.create(user_id: current_user.id)
      @topic = @post.topic
      @topic.touch
      @post.reload
      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          post: @post,
          topic: @topic,
        }
      }
    end
  end

  def post_params
    params.require(:post).permit(
      :body,
      :kind,
      {attachments: []}
    )
  end

end
