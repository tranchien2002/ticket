#done
class CategoriesController < ApplicationController

  before_action :knowledgebase_enabled?, only: ['index','show']
  skip_before_action :verify_authenticity_token, raise: false
  # theme :theme_chosen
  before_action :verify_admin_and_agent

  def index
    @categories = Category.publicly.active.ordered
    @page_title = "Thông tin cơ bản"

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        categories: @categories,
        page_title: @page_title
      }
    }
  end

  def show
    GeneralHelpers.params_validation(:get, :show_category, params)
    @category = Category.publicly.active.where(id: params[:id]).first
    if @category
      @docs = @category.docs.ordered.active.page params[:page]
      @categories = Category.publicly.active.ordered
      @related = Doc.in_category(@doc.category_id) if @doc

      @page_title = @category.name
      render json: {
        code: Settings.code.success,
        message: "",
        data: {
          docs: @docs,
          categories: @categories,
          related: @related,
          page_title: @page_title
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
