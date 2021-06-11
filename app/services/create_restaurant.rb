# frozen_string_literal: true

require 'http'

module RestaurantCollections
  # Returns an authenticated user, or nil
  class CreateRestaurant
    # Error for accounts that cannot be created
    class InvalidRestaurant < StandardError
      def message
        'This restaurant can no longer be created: please start again'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(current_account:, restaurant_data:)
        puts "Entered restaurant service with data: #{restaurant_data}"
      message = { name: restaurant_data[:name],
                  website: restaurant_data[:website],
                  address: restaurant_data[:address],
                  menu: restaurant_data[:menu]
                }

      response = HTTP.post(
        "#{@config.API_URL}/restaurants/",
        json: message
      )

      puts "Response: #{response.body}"

      raise InvalidRestaurant unless response.code == 201
    end
  end
end
