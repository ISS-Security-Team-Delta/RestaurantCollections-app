# frozen_string_literal: true

require_relative 'restaurant'

module RestaurantCollections
  # Behaviors of the currently logged in account
  class Restaurants
    attr_reader :all

    def initialize(restaurants_list)
      @all = restaurants_list.map do |rest|
        Restaurant.new(rest)
      end
    end
  end
end
