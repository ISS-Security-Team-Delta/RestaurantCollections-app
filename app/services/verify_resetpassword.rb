# frozen_string_literal: true

require 'http'

module RestaurantCollections
  # Returns an authenticated user, or nil
  class VerifyResetPassword
    class VerificationError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(resetpwd_data)
      # reset pwd token will expire after an hour
      resetpwd_token = SecureMessage.encrypt(resetpwd_data)
      resetpwd_data['verification_url'] =
        "#{@config.APP_URL}/auth/resetpwd/#{resetpwd_token}"

      response = HTTP.post("#{@config.API_URL}/auth/resetpwd",
                           json: SignedMessage.sign(resetpwd_data))
      raise(VerificationError) unless response.code == 202
      JSON.parse(response.to_s)
    end
  end
end
