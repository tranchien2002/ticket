class Api::V1::Admin::OnboardingController < Api::V1::Admin::BaseController

  before_action :allow_onboarding, except: 'complete'
  before_action :verify_admin
  skip_before_action :verify_authenticity_token, raise: false

  def index
    @user = current_user
    @user.name = ""
    @user.email = ""

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        user: @user
      }
    }
  end

  def update_settings
    @settings = AppSettings.get_all

    @settings.each do |setting|
      AppSettings[setting[0]] = params[setting[0].to_sym] unless params[setting[0].to_sym].nil?
    end

    render json: {
      code: Settings.code.success,
      message: "Chỉnh sửa thành công",
      data: {
        redirect_to: admin_settings_path,
        js: "Helpy.showPanel(3);$('#edit_user_1').enableClientSideValidations();"
      }
    }
  end

  protected

  def allow_onboarding
    unless show_onboarding?
      redirect_path({admin_complete_onboard_path: admin_complete_onboard_path}) && return
    end
  end
end
