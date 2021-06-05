# frozen_string_literal: true

require_relative 'restaurant'

module RestaurantCollections
  # Behaviors of the currently logged in account
  class Restaurant
    attr_reader :id, :name, :repo_url

    def initialize(rest_info)
      @id = rest_info['attributes']['id']
      @website = rest_info['attributes']['website']
      @name = rest_info['attributes']['name']
      @address = rest_info['attributes']['address']
      @menu = rest_info['attributes']['menu']
    end
  end
end
