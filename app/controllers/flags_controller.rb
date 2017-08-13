#done
class FlagsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin_and_agent

  def create
    GeneralHelpers.params_validation(:create, :create_flag, params)
    @post = Post.find_by_id(params[:post_id])
    @topic = Topic.find_by_id(@post.topic_id)
    @forum = Forum.isprivate.first
    @reason = params[:flag][:reason]
    @user = current_user

    @flag = Flag.new(
      post_id: @post.id,
      reason: @reason
    )

    if @flag.save
      raise APIError::Common::NotFound.new(
        {
          status: 404,
          message: "Không tìm thấy dữ liệu"
        }
      ) unless @forum || @user || @topics

      @topics = @forum.topics.new(
      name: "Flagged for review: #{@topic.name}",
      private: true)

      @topics.user_id = @user.id

      if @topics.save
        @topics.posts.create(
          :body => "Reason for flagging: #{@flag.reason}\nTo view this post #{view_context.link_to 'Click Here', admin_topic_path(@topic)}",
          :user_id => @user.id,
          :kind => 'first'
          )

        @flag.update_attribute(:generated_topic_id, @topics.id)

        # redirect_to posts_path(@post)
        render json: {
          code: Settings.code.success,
          status: 201,
          message: "Bài đăng đã được cắm cờ"
        }
      end
    end
  end

  def new
  end

  def index
  end
end
