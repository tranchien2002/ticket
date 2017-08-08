class Api::V1::Admin::DocsController < Api::V1::Admin::BaseController

  before_action :verify_admin
  skip_before_filter :verify_authenticity_token

  def new
    GeneralHelpers.params_validation(:new, :new_doc, params)
    @doc = Doc.new
    @doc.category_id = params[:category_id]
    if params[:post_id]
      post = Post.where(id: params[:post_id]).first
      @doc.body = post.body if post
    end

    @categories = Category.alpha
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        doc: @doc,
        categories: @categories
      }
    }
  end

  def edit
    GeneralHelpers.params_validation(:edit, :edit_doc, params)
    @doc = Doc.find_by(id: params[:id])
    @category = Category.where(id: params[:category_id]).first
    @categories = Category.alpha

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        doc: @doc,
        category: @category
        categories: @categories
      }
    }
  end

  def create
    GeneralHelpers.params_validation(:create, :create_doc, params)
    @doc = Doc.new(doc_params)
    @doc.user_id = current_user.id
    if @doc.save
      redirect_path({admin_category_path: admin_category_path(@doc.category.id)}) && return
    else
      raise APIError::Common::ServerError.new(
        {
          status: 500,
          message: "Không thể tạo tài liệu"
        }
      )
    end
  end

  def update
    GeneralHelpers.params_validation(:update, :update_doc, params)
    @doc = Doc.where(id: params[:id]).first
    @category =  @doc.nil? ? nil : @doc.category
    if @doc.update_attributes(doc_params)
      redirect_path({admin_category_path: admin_category_path(@category.id)}) && return
    else
      raise APIError::Common::ServerError.new(
        {
          status: 500,
          message: "Không thể cập nhật tài liệu này"
          data: {
            doc: @doc
          }
        }
      )
    end

  end

  def destroy
    GeneralHelpers.params_validation(:destroy, :destroy_doc, params)
    @doc = Doc.find_by(id: params[:id])
    if @doc
      @doc.destroy

      if @doc.destroyed?
        render json: {
          code: Settings.code.success,
          message: "Xóa tài liệu thành công"
          data: {
            js:"
            $('#doc-#{@doc.id}').fadeOut();
            Helpy.ready();
            Helpy.track();"
          }
        }
      else
        raise APIError::Common::ServerError.new(
          status: 404,
          message: "Không xóa được tài liệu"
        )
      end
    end
  end

  private

  def doc_params
    params.require(:doc).permit(
    :title,
    :body,
    :keywords,
    :title_tag,
    :meta_description,
    :category_id,
    :rank,
    :active,
    :front_page,
    :allow_comments,
    {screenshots: []},
    :tag_list
  )
  end

end
