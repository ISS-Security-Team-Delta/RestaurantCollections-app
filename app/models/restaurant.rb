# frozen_string_literal: true

require_relative 'restaurant'

module RestaurantCollections
  # Behaviors of the currently logged in account
  class Restaurant
    attr_reader :id, :website, :name, :address,
                :owner, :collaborators, :comments, :meals, :policies

    def initialize(rest_info)
      process_attributes(rest_info['attributes'])
      process_relationships(rest_info['relationships'])
      process_policies(rest_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @website = attributes['website']
      @name = attributes['name']
      @address = attributes['address']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @collaborators = process_collaborators(relationships['collaborators'])
      @comments = process_comments(relationships['comments'])
      @meals = process_meals(relationships['meals'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_comments(comments_info)
      return nil unless comments_info

      comments_info.map { |com_info| Comment.new(com_info) }
    end

    def process_meals(meals_info)
      return nil unless meals_info

      meals_info.map { |meal_info| Meal.new(meal_info) }
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info) }
    end
  end
end
