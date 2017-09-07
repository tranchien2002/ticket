require "application_responder"

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # helper_method :recaptcha_enabled?
  # before_action :set_vars
  # around_action :set_time_zone, if: :current_user

  rescue_from APIError::Base do |e|
    key_error = e.class.name.split("::").drop(1).map(&:underscore)
    data = nil
    if e.message.is_a?(Hash)
      error_code = e.message[:status]
      message = e.message[:message]
      if e.message.has_key?(:data)
        data = e.message[:data]
      end
    else
      error_code = Settings.error_codes[key_error[0].to_sym][key_error[1].to_sym]
      message = e.message
    end

    render json: {
      :code => 0, :message => message
    }.merge!(data.present? ? {} : {data: data}) , :status => error_code
  end

  respond_to :json


  #8/8

  def authenticate_user
    raise APIError::Common::Unauthorized if session[:user]["uid"].nil?
  end

  def login_required
    redirect_to "#{Settings.chungcu}/auth/sso" unless session[:user]
  end

  def current_user
    return unless session[:user]
    @current_user ||= User.find_by(uid: session[:user]["uid"])
  end

  def check_BuildingManager
    check_access_role(__method__.to_s)
  end

  def check_Technician_and_Cashier
    check_access_role(__method__.to_s)
  end

  def check_agent
    check_access_role(__method__.to_s)
  end

  def check_admin
    check_access_role(__method__.to_s)
  end

  def check_admin_and_agent
    check_access_role(__method__.to_s)
  end

  def user_signed_in?
    return true if session[:user]
    return false
  end

  def save_files_with_token dir, files
    file_name_list = [];
    begin
      files.each do |file|
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        extn = File.extname file.original_filename
        name = File.basename(file.original_filename, extn).gsub(/[^A-z0-9]/, "_")
        full_name = name + "_" + SecureRandom.hex(5) + extn
        file_name_list.push full_name
        path = File.join(dir, full_name)
        File.open(path, "wb") { |f| f.write file.read }
      end
      return file_name_list
    rescue
      return []
    end
  end

  def recaptcha_enabled?
    AppSettings['settings.recaptcha_enabled'] == '1' && AppSettings['settings.recaptcha_site_key'].present? && AppSettings['settings.recaptcha_api_key'].present?
  end

  def cloudinary_enabled?
    AppSettings['cloudinary.enabled'] == '1' && AppSettings['cloudinary.cloud_name'].present? && AppSettings['cloudinary.api_key'].present? && AppSettings['cloudinary.api_secret'].present?
  end
  helper_method :cloudinary_enabled?

  def tracker(ga_category, ga_action, ga_label, ga_value=nil)
    if AppSettings['settings.google_analytics_id'].present? && cookies['_ga'].present?
      ga_cookie = cookies['_ga'].split('.')
      ga_client_id = ga_cookie[2] + '.' + ga_cookie[3]
      logger.info("Enqueing job for #{ga_client_id}")

      TrackerJob.perform_later(
        ga_category,
        ga_action,
        ga_label,
        ga_value,
        ga_client_id,
        AppSettings['settings.google_analytics_id']
      )
    end
  end

  def google_analytics_enabled?
    AppSettings['settings.google_analytics_enabled'] == '1'
  end
  helper_method :google_analytics_enabled?

  def welcome_email?
    AppSettings['settings.welcome_email'] == "1" || AppSettings['settings.welcome_email'] == true
  end
  helper_method :welcome_email?

  def forums?
    AppSettings['settings.forums'] == "1" || AppSettings['settings.forums'] == true
  end
  helper_method :forums?

  def knowledgebase?
    AppSettings['settings.knowledgebase'] == "1" || AppSettings['settings.knowledgebase'] == true
  end
  helper_method :knowledgebase?

  def tickets?
    AppSettings['settings.tickets'] == "1" || AppSettings['settings.tickets'] == true
  end
  helper_method :tickets?

  def teams?
    AppSettings['settings.teams'] == "1" || AppSettings['settings.teams'] == true
  end
  helper_method :teams?

  def forums_enabled?
    raise ActionController::RoutingError.new('Not Found') unless forums?
  end

  def knowledgebase_enabled?
    raise ActionController::RoutingError.new('Not Found') unless knowledgebase?
  end

  def tickets_enabled?
    raise ActionController::RoutingError.new('Not Found') unless tickets?
  end

  def topic_creation_enabled?
    raise ActionController::RoutingError.new('Not Found') unless tickets? || forums?
  end

  protected

  private

  def controller_namespace_origin
    controller_path.split('/').first
  end

  def set_vars
    # Configure griddler, mailer, cloudinary, recaptcha
    Griddler.configuration.email_service = AppSettings["email.mail_service"].present? ? AppSettings["email.mail_service"].to_sym : :sendgrid

    ActionMailer::Base.smtp_settings = {
        :address              => AppSettings["email.mail_smtp"],
        :port                 => AppSettings["email.mail_port"],
        :user_name            => AppSettings["email.smtp_mail_username"].presence,
        :password             => AppSettings["email.smtp_mail_password"].presence,
        :domain               => AppSettings["email.mail_domain"],
        :enable_starttls_auto => !AppSettings["email.mail_smtp"].in?(["localhost", "127.0.0.1", "::1"])
    }

    ActionMailer::Base.perform_deliveries = to_boolean(AppSettings['email.send_email'])

    Cloudinary.config do |config|
      config.cloud_name = AppSettings['cloudinary.cloud_name'].blank? ? nil : AppSettings['cloudinary.cloud_name']
      config.api_key = AppSettings['cloudinary.api_key'].blank? ? nil : AppSettings['cloudinary.api_key']
      config.api_secret = AppSettings['cloudinary.api_secret'].blank? ? nil : AppSettings['cloudinary.api_secret']
      config.secure = true
    end

    Recaptcha.configure do |config|
      config.public_key  = AppSettings['settings.recaptcha_site_key'].blank? ? nil : AppSettings['settings.recaptcha_site_key']
      config.private_key = AppSettings['settings.recaptcha_api_key'].blank? ? nil : AppSettings['settings.recaptcha_api_key']
      # Uncomment the following line if you are using a proxy server:
      # config.proxy = 'http://myproxy.com.au:8080'
    end

  rescue
    logger.warn("WARNING!!! Error setting configs.")
    if AppSettings['email.mail_service'] == 'mailin'
      AppSettings['email.mail_service'] == ''
    end
  end

  def to_boolean(str)
    str == 'true'
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def theme_chosen
    if params[:theme].present?
      params[:theme]
    else
      AppSettings['theme.active'].present? ? AppSettings['theme.active'] : 'helpy'
    end
  end

  # def set_time_zone(&block)
  #   Time.use_zone(current_user.time_zone, &block)
  # end

  def get_all_teams
    return unless teams?
    @all_teams = ActsAsTaggableOn::Tagging.all.where(context: "teams").includes(:tag).map{|tagging| tagging.tag.name.capitalize }.uniq
    return @all_teams
  end

  def redirect_path path, extra_data = {}
    render json: {
      code: Settings.code.success,
      message: "Chuyển hướng",
      data: {
        redirect_to: path,
        extra_data: extra_data
      }
    }
  end

  private
  def check_access_role(method_name)
    method_name.slice!("check_")
    method_name = method_name.split("_and_")
    if current_user
      method_name.each do |m|
        return true if current_user.role == m
      end
    end
    raise APIError::Common::Unauthorized.new
  end

end
