require "omniauth-oauth2"
module OmniAuth
  module Strategies
    class Sso < OmniAuth::Strategies::OAuth2

      CUSTOM_PROVIDER_URL = "http://localhost:3000"

      option :client_options, {
        site: CUSTOM_PROVIDER_URL,
        authorize_url: "#{CUSTOM_PROVIDER_URL}/auth/sso/authorize",
        access_token_url: "#{CUSTOM_PROVIDER_URL}/auth/sso/access_token"
      }

      uid do
        raw_info["id"]
      end

      info do
        {
          name: raw_info["info"]["username"],
          email: raw_info["info"]["email"],
          role: raw_info["info"]["role"],
          phone: raw_info["info"]["phone"],
          phone2: raw_info["info"]["phone2"]
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/auth/sso/user.json?oauth_token=#{access_token.token}").parsed
      end
    end
  end
end
