# frozen_string_literal: true

require 'http'

module RestaurantCollections
  # Returns an authenticated user, or nil
  class ResetPwd
    class InvalidAccount < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(email:, password:)
      account = { email: email,
                  password: password }

      response = HTTP.post(
        "#{@config.API_URL}/accounts/resetpwd",
        json: SignedMessage.sign(account)
      )

      raise InvalidAccount unless response.code == 201
    end
  end
end
