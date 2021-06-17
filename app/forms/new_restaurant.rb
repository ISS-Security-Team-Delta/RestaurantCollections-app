# frozen_string_literal: true

require_relative 'form_base'

module RestaurantCollections
  module Form
    # Add new restaurant form class
    class NewRestaurant < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_restaurant.yml')

      params do
        required(:name).filled
        required(:website).filled(format?: URI::DEFAULT_PARSER.make_regexp)
        required(:address).filled
        required(:menu).filled
      end
    end
  end
end
