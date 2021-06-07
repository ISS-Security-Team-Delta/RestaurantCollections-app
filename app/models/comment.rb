# frozen_string_literal: true

require_relative 'restaurant'

module RestaurantCollections
  # Behaviors of the currently logged in account
  class Comment
    attr_reader :id, :content, :like, # basic info
                :restaurant # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @content        = attributes['content']
      @like           = attributes['like']
    end

    def process_included(included)
      @restaurant = Restaurant.new(included['restaurant'])
    end
  end
end
