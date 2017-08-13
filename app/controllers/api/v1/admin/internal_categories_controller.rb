class Api::V1::Admin::InternalCategoriesController < Api::V1::Admin::BaseController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin

  def index
    @categories = Category.internally.without_system_resource.ordered

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        categories: @categories
      }
    }
  end

  def show
    GeneralHelpers.params_validation(:get, :show_internal_category, params)
    @category = Category.internally.without_system_resource.active.where(id: params[:id]).first
    if @category
      @docs = @category.docs.ordered.active.page params[:page]

      @page_title = @category.name

      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          page_title: @page_title,
          docs: @docs,
          category: @category
        }
      }
    else
      raise APIError::Common::NotFound.new(
        {
          status: 404,
          message: "Không tìm thấy chuyên mục"
        }
      )
    end
  end

end
