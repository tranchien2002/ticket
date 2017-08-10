#done
class CommentsController < ApplicationController

  before_action :authenticate_user!
  before_action :get_doc
  skip_before_filter :verify_authenticity_token
  before_action :verify_admin_and_agent

  # This method handles the first comment and subsequent replies, storing them
  # as a Topic with Posts
  def create
    GeneralHelpers.params_validation(:create, :create_comment, params)

    if @doc.topic.blank?
      @topic = Topic.create_comment_thread(@doc.id, current_user.id)
    else
      @topic = Topic.where(doc_id: @doc.id).first
    end
    @post = @topic.posts.new(comment_params)
    @post.user_id = current_user.id
    @post.screenshots = params[:post][:screenshots]

    if @post.save
      redirect_path({doc_relative_path: doc_relative_path(params[:request][:origin]}, @doc) && return
    else
      raise APIError::Common::ServerError.new({status: 500, message: "Lưu bài đăng thất bại"})
    end


  end

  private

  def comment_params
    params.require(:post).permit(
      :body,
      :kind,
      :user_id,
      {attachments: []}
    )
  end

  def get_doc
    GeneralHelpers.params_validation(:get, :get_doc, params)
    @doc = Doc.find_by(id: params[:doc_id])
  end

  def doc_relative_path(origin, doc)
    if origin == 'internal'
      admin_internal_category_internal_doc_path(doc.category.id, doc.id)
    else
      doc_path(doc)
    end
  end

end
