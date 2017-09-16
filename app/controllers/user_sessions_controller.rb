class UserSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :login_required, only: :destroy

  def create
    omniauth = request.env["omniauth.auth"]
    user = User.find_by_uid(omniauth["uid"]) || User.new
    user.uid = omniauth["uid"]
    user.name = omniauth["info"]["name"]
    user.email = omniauth["info"]["email"]
    user.role = omniauth["info"]["role"]
    user.phone = omniauth["info"]["phone"]
    user.avatar = omniauth["info"]["avatar"]
    user.building_id = omniauth["info"]["building_id"].to_i
    raise APIError::Common::UnSaved unless user.save
    session[:user] = omniauth
    render json: {code: 1, message: "Thành công"}
  end

  def failure
    flash[:notice] = params[:message]
  end

  def destroy
    session[:user] = nil
    redirect_to "#{Settings.chungcu}/users/sign_out"
  end
end
