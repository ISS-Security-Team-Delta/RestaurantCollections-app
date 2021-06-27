# frozen_string_literal: true

require 'http'

module RestaurantCollections
  # Returns an authenticated user, or nil
  class ResetPwd
    # Error for accounts that cannot be reset
    class InvalidAccount < StandardError
      def message
        'This password cannot be reseted: please check again'
      end
    end

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
