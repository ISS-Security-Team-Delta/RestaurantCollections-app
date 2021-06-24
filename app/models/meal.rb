# frozen_string_literal: true

require_relative 'restaurant'

module RestaurantCollections
  # Behaviors of the currently logged in account
  class Meal
    attr_reader :id, :name, :description, :type, :price, # basic info
                :restaurant # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['included'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @name           = attributes['name']
      @description    = attributes['description']
      @type           = attributes['type']
      @price          = attributes['price']
    end

    def process_included(included)
      @restaurant = Restaurant.new(included['restaurant'])
    end
  end
end
