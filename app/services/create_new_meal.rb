# frozen_string_literal: true

require 'http'

# Create a new configuration file for a restaurant
class CreateNewMeal
  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, restaurant_id:, meal_data:)
    config_url = "#{api_url}/restaurants/#{restaurant_id}/meals"
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .post(config_url, json: meal_data)

    response.code == 201 ? JSON.parse(response.body.to_s) : raise
  end
end