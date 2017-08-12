#done
class DocsController < ApplicationController

  before_action :knowledgebase_enabled?, only: ['show']
  before_action :doc_available_to_view?, only: ['show']
  after_action  :is_user_signed_in?
  theme :theme_chosen
  skip_before_filter :verify_authenticity_token
  before_action :verify_admin_and_agent

  def show
    define_topic_for_doc
    define_forum_for_docs
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        forum: @forum,
        comment: @comment,
        post: @post,
        posts: @posts,
        topic: @topic
      }
    }
  end

  private

  def doc_available_to_view?
    GeneralHelpers.params_validation(:get, :doc_available_to_view, params)
    @doc = Doc.find_by(id: params[:id], active: true)
    if @doc.nil?
      raise APIError::Common::NotFound.new(
        {
          status: 404,
          message: "Không tìm thấy tài liệu"
        }
      )
    else
      !@doc.category.publicly_viewable?
    end
  end

  def is_user_signed_in?
    @user = User.new unless user_signed_in?
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        user: @user
      }
    }
  end

  def define_forum_for_docs
    @forum = Forum.for_docs.first
    @comment = @forum.topics.new
  end

  def define_topic_for_doc
    posts = nil
    if @doc.topic.present?
      @topic  = @doc.topic
      @post   = @topic.posts.new
      @posts  = @topic.posts.ispublic.active.includes(:user) unless @topic.nil?
    else
      @topic  = Topic.new
      @post   = Post.new
    end
  end

end
