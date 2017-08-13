class Api::V1::Admin::PostsController < Api::V1::Admin::BaseController

  before_action :verify_admin
  skip_before_action :verify_authenticity_token, raise: false

  def edit
    GeneralHelpers.params_validation(:edit, :admin_edit_post, params)
    @post = Post.where(id: params[:id]).first

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        post: @post
      }
    }
  end

  def cancel
    GeneralHelpers.params_validation(:get, :admin_cancel_post, params)
    @post = Post.where(id: params[:id]).first

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        post: @post
      }
    }
  end

  def create
    GeneralHelpers.params_validation(:create_post, :admin_create_post, params)
    @topic = Topic.find_by_id(params[:topic_id])
    @post = Post.new(post_params)

    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy topic"
    ) unless @topic

    @post.topic_id = @topic.id
    @post.user_id = current_user.id
    get_all_teams

    if @post.save
      if params[:post][:resolved] == "1"
        @topic.close(current_user.id)
        tracker("Agent: #{current_user.name}", "Closed", @topic.to_param) #TODO: Need minutes
      end

      fetch_counts
      @posts = @topic.posts.chronologic

      @admins = User.agents
      case @post.kind
      when "reply"
        tracker("Agent: #{current_user.name}", "Agent Replied", @topic.to_param) #TODO: Need minutes
      when "note"
        tracker("Agent: #{current_user.name}", "Agent Posted Note", @topic.to_param) #TODO: Need minutes
      end

      render json: {
        code: Settings.code.success,
        message: "Đã lưu bài đăng",
        data: {
          redirect_to: [
            admin_topic_path(@post.topic_id)
          ],
          admins: @admins,
          topic: @topic,
          posts: @posts
        }
      }
    else
      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          redirect_to: [
            new_admin_topic,
            admin_topic_path(@post.topic_id)
          ]
        }
      }
    end
  end

  def update
    GeneralHelpers.params_validation(:update, :admin_update_post, params)
    @post = Post.find_by_id(params[:id])
    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy bài đăng"
    ) unless @post

    old_user = @post.user

    fetch_counts
    get_all_teams
    @topic = @post.topic
    @posts = @topic.posts.chronologic

    if @post.update_attributes(post_params)
      update_topic_owner(old_user, @post) if @post.kind == 'first'
      render json: {
        code: Settings.code.success,
        message: "Cập nhật bài đăng thành công"
      }
    else
      raise APIError::Common::ServerError.new(
        {
          status: 500,
          message: "Cập nhật bài đăng thất bại"
        }
      )
    end
  end

  def search
    GeneralHelpers.params_validation(:get, :admin_search_post, params)
    search_string = params[:user_search]
    @post_id = params[:post_id]
    @users = User.user_search(search_string)
    @users = nil if search_string.blank? || @users.empty?
    render json: {
      code:Settings.code.success,
      message: "",
      data: {
        users: @users
      }
    }
  end

  def new_user
    GeneralHelpers.params_validation(:new, :admin_new_user, params)
    @post_id = params[:post_id]
    @user = User.new

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        user: @user
      }
    }
  end

  def change_owner_new_user
    GeneralHelpers.params_validation(:update, :change_owner_new_user, params)
    @post = Post.find_by_id(params[:post_id])
    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy bài đăng"
      }
    ) unless @post

    old_user = @post.user

    fetch_counts
    get_all_teams
    @topic = @post.topic
    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy Topic"
      }
    ) unless @topic

    @posts = @topic.posts.chronologic

    # Check user doesnt exist
    @user = User.find_by(email: params[:user][:email])

    # create user
    if @user.nil?
      @user = User.new

      # @token, enc = ApplicationHelper.generate_token(User, :reset_password_token)

      @user.name = params[:user][:name]
      @user.login = params[:user][:email].split("@")[0]
      @user.email = params[:user][:email]
    end

    # assign user
    if @user.save && @post.update(user: @user)
      update_topic_owner(old_user, @post) if @post.kind == 'first'
    end

    # re render topic
    redirect_path({update_admin_post: 'admin/posts/update'}) && return
  end

  def raw
    GeneralHelpers.params_validation(:get, :post_raw, params)
    @post = Post.find_by_id(params[:id])
    render json: {
      code: Settings.code.success,
      message: "raw",
      data: {
        post: @post
      }
    }
  end

  private

  def post_params
    params.require(:post).permit(
      :body,
      :kind,
      {screenshots: []},
      {attachments: []},
      :cc,
      :bcc,
      :user_id,
    )
  end

  def update_topic_owner(old_owner, post)
      return if old_owner == post.user

      topic = post.topic
      topic.update(user: post.user)
      topic.posts.create(
        user: current_user,
        body: I18n.t('change_owner_note', old: old_owner.name, new: post.user.name, default: "The creator of this topic was changed from #{old_owner.name} to #{post.user.name}"),
        kind: "note",
      )

  end
end
