class Api::V1::Admin::InternalDocsController < Api::V1::Admin::BaseController
  before_action :knowledgebase_enabled?, only: ['show']
  before_action :doc_available_to_view?, only: ['show']
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin

  # respond_to :html

  def show
    define_topic_for_doc
    define_forum_for_docs
  end

  private

  def doc_available_to_view?
    GeneralHelpers.params_validation(:get, :doc_available_to_view, params)
    @doc = Doc.find_by(id: params[:id], active: true)

    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy tài liệu"
    ) if @doc.nil? || !@doc.category.internally_viewable?
  end

  def define_forum_for_docs
    @forum = Forum.for_docs.first
    @comment = @forum.topics.new
  end

  def define_topic_for_doc
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
