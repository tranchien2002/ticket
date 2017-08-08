APP_ID = 'helpy_key'
APP_SECRET = 'helpy_secret'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :sso, APP_ID, APP_SECRET
end
