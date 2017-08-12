require_relative 'boot'

require 'rails/all'
require "attachinary/orm/active_record"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ticket
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.paths.add File.join("app", "api"), glob: File.join("**", "*.rb")
    config.autoload_paths += Dir[Rails.root.join("app", "api", "*")]
    config.i18n.default_locale = :vi

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins /.*/
        resource "*", headers: :any, methods: :any, credentials: true
      end
    end

  end
end
