class Api::V1::Admin::CategoriesController < Api::V1::Admin::BaseController
  before_action :set_categories_and_non_featured, only: [:index, :create]
  before_action :verify_admin
  skip_before_action :verify_authenticity_token, raise: false

  def index
  end

  def show
    GeneralHelpers.params_validation(:create, :create_category, params)
    @category = Category.where(id: params[:id]).first
    @docs = @category.nil? ? nil : @category.docs.ordered
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        category: @category,
        docs: @docs
      }
    }
  end

  def create
    GeneralHelpers.params_validation(:create, :create_category, params)
    @category = Category.new(category_params)
    if @category.save
      render json: {
        code: Settings.code.success,
        message: "Tạo chuyên mục thành công",
        data: {
          category: @category,
        }
      }
    else
      raise APIError::Common::ServerError.new(
        {
          status: 500,
          message: "Xảy ra lỗi hệ thống khi lưu thông tin"
        }
      )
    end
  end

  def update
    GeneralHelpers.params_validation(:update, :update_category, params)
    @category = Category.find_by(id: params[:id])
    if @category.update(category_params)
      redirect_path({admin_categories_path: admin_categories_path}) && return
    else
      raise APIError::Common::ServerError.new(
        {
          status: 500,
          message: "Xảy ra lỗi hệ thống khi lưu thông tin"
        }
      )
    end
  end

  def destroy
    GeneralHelpers.params_validation(:destroy, :destroy_category, params)
    @category = Category.find_by(id: params[:id])
    if @category
      @category.destroy

      if @category.destroyed?
        render json: {
          code: Settings.code.success,
          message: "Xóa chuyên mục thành công"
        }
      else
        raise APIError::Common::ServerError.new(
          status: 404,
          message: "Không xóa được chuyên mục"
        )
      end
    end
  end

  private

  def category_params
    params.require(:category).permit(
    :name,
    :keywords,
    :title_tag,
    :icon,
    :meta_description,
    :front_page,
    :active,
    :section,
    :rank,
    :team_list,
    :visibility
  )
  end

  def set_categories_and_non_featured
    @public_categories = Category.publicly.featured.ordered
    @public_nonfeatured_categories = Category.publicly.unfeatured.alpha
    @internal_categories = Category.only_internally.ordered
  end


end
