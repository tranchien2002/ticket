class Api::V1::Admin::ImagesController < Api::V1::Admin::BaseController

  before_action :verify_admin
  skip_before_action :verify_authenticity_token, raise: false

  def create
    GeneralHelpers.params_validation(:create, :create_image, params)
    @image = Image.new(image_params)
    raise APIError::Common::ServerError.new(
      {
        status: 500,
        message: "Không thể lưu ảnh"
      }
    ) unless @image.save

    render json: {
      code: Settings.code.success,
      message: "Lưu ảnh thành công",
      data: {
        image_id: @image.id,
        url: @image.file.url
      }
    }
  end

  def destroy
    GeneralHelpers.params_validation(:destroy, :destroy_image, params)
    @image = Image.find_by_id(params[:id])
    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy ảnh"
    ) unless @image

    @image.destroy

    if @image.destroyed?
      render json: {
        code: Settings.code.success,
        message: "Xóa ảnh thành công"
      }
    else
      raise APIError::Common::ServerError.new(
        status: 404,
        message: "Không xóa được ảnh"
      )
    end

  end

  private

  def image_params
    params.require(:image).permit(
      :name,
      :extension,
      :file
    )
  end

end
