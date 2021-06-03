# frozen_string_literal: true

require 'http'

module RestaurantCollections
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    class UnauthorizedError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate",
                           json: { username: username, password: password })

      raise(UnauthorizedError) unless response.code == 200

      # response.parse['attributes']
      account_info = JSON.parse(response.to_s)['attributes']
      puts account_info
      {
        account: account_info['account']['attributes'],
        auth_token: account_info['auth_token']
      }
    end
  end
end
