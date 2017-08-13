class Api::V1::Admin::SharedController < Api::V1::Admin::BaseController

  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_admin

  def update_order
    GeneralHelpers.params_validation(:update, :admin_update_order, params)
    # Safely identify the model we're updating the position of
    klass = [Category, Doc].detect { |c| c.name.casecmp(params[:object]) == 0 }
    @obj = klass.find_by_id(params[:obj_id])
    raise APIError::Common::NotFound.new(
      status: 404,
      message: "Không tìm thấy đối tượng"
    ) unless @obj

    @obj.rank_position = params[:row_order_position]
    if @obj.save
      render json: {
        code: Settings.code.success,
        message: "Cập nhật thứ hạng thành công"
      }
    else
      raise APIError::Common::ServerError.new(
        status: 500,
        message: "Không cập nhật được thứ tự"
      )
    end
  end

end
