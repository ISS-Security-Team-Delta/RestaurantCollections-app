# frozen_string_literal: true

require_relative 'form_base'

module RestaurantCollections
  module Form
    class NewMeal < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_meal.yml')

      params do
        required(:name).filled
        required(:description).filled
        required(:type).filled
        required(:price).filled.value(:integer)
      end

      rule(:type) do
        puts "The type was: #{value}"
        key.failure('Not a valid type') if value != 'Breakfast' &&
                                           value != 'Brunch' &&
                                           value != 'Lunch' &&
                                           value != 'Dinner' &&
                                           value != 'Drink'
      end

      rule(:price) do
        key.failure('Must be less than $2,000,000') if value >= 2_000_000
      end
    end
  end
end