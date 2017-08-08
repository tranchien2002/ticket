require 'openssl'

module ApplicationHelper
  extend self

  def self.friendly_token
    SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
  end

  def self.generate_token(klass, column)
    key = key_for(column)

    loop do
      raw = ApplicationHelper.friendly_token
      enc = OpenSSL::HMAC.hexdigest("SHA256", key, raw)
      break [raw, enc] unless klass.to_adapter.find_first({ column => enc })
    end
  end

  def bootstrap_class_for flash_type
    if ["error", "alert"].include? flash_type
      "alert-danger"
    else
      "alert-success"
    end
  end

end
