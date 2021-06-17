# frozen_string_literal: true

require 'http'

# Returns all restaurants belonging to an account
class GetRestaurant
  def initialize(config)
    @config = config
  end

  def call(current_account, rest_id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/restaurants/#{rest_id}")

    response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
  end
end