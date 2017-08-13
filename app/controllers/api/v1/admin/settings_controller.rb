class Api::V1::Admin::SettingsController < Api::V1::Admin::BaseController

  before_action :verify_admin
  skip_before_action :verify_authenticity_token, raise: false

  def index
    @settings = AppSettings.get_all
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: "admin",
        settings: @settings
      }
    }
  end

  def general
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def design
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def theme
    @themes = Theme.find_all
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings',
        themes: @themes
      }
    }
    render layout: 'admin-settings'
  end

  def widget
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def i18n
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def email
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def integration
    # Set the webhook key if its blank
    AppSettings["webhook.form_key"] = SecureRandom.hex if AppSettings["webhook.form_key"].blank?
    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def profile
    @user = User.find_by_id(current_user.id)
    raise APIError::Common::NotFound.new(
      {
        status: 404,
        message: "Không tìm thấy người dùng"
      }
    ) unless @user

    tracker("Agent: #{current_user.name}", "Editing User Profile", @user.name)

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        layout: 'admin-settings'
      }
    }
  end

  def preview
    GeneralHelpers.params_validation(:get, :preview, params)
    theme = Theme.find_by_id(params[:theme])
    send_file File.join(theme.path, theme.thumbnail),
            type: 'image/png', disposition: 'inline', stream: false
  end

  def update_settings
    # NOTE: We iterate through settings here to establish our universe of settings to save
    # this means if you add a setting, you MUST declare a default value in the "default_settings intializer"
    @settings = AppSettings.get_all
    # iterate through
    @settings.each do |setting|
      AppSettings[setting[0]] = params[setting[0].to_sym] if params[setting[0].to_sym].present?
    end

    @logo = Logo.new
    @logo.file = params['uploader.design.header_logo']
    @logo.save

    @thumb = Logo.new
    @thumb.file = params['uploader.design.favicon']
    @thumb.save

    render json: {
      code: Settings.code.success,
      message: "",
      data: {
        redirect_to: admin_settings_path,
        site_url: AppSettings['settings.site_url'],
        settings_changes_saved: "The changes you have been saved. " +
          "Some changes are only visible on your helpcenter site: #{AppSettings['settings.site_url']}"
      }
    }
  end


end
