class SessionsController < ApplicationController
  # theme :theme_chosen
  before_action :login_required, only: :destroy

  def create
    omniauth = request.env['omniauth.auth']
    if ["admin", "agent"].include?(omniauth['info']['role'])
      user = User.find_by_uid(omniauth['uid'])
      unless user
        user = User.new
        user.uid = omniauth['uid']
        user.name = omniauth['info']['name']
        user.email = omniauth['info']['email']
        user.role = omniauth['info']['role']
        user.phone = omniauth['info']['phone']
        user.phone2 = omniauth['info']['phone2']
        unless user.save
          raise APIError::Common::ServerError.new
        end
      end
      session[:user_id] = omniauth
    end
    render json: {code: 1, message: session[:user_id]}
  end

  def failure
    flash[:notice] = params[:message]
  end

  def destroy
    session[:user_id] = nil
    redirect_to "#{CUSTOM_PROVIDER_URL}/users/sign_out"
  end
end
