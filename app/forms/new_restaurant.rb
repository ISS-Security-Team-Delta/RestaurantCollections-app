# frozen_string_literal: true

require_relative 'form_base'

module RestaurantCollections
  module Form
    # Add new restaurant form class
    class NewRestaurant < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_restaurant.yml')

      params do
        required(:name).filled
        required(:rest_url).filled(format?: URI::DEFAULT_PARSER.make_regexp)
        required(:rest_add).filled
        required(:rest_menu).filled
      end
    end
  end
end
