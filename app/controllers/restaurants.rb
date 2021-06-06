# frozen_string_literal: true

require 'roda'

module RestaurantCollections
  # Web controller for Credence API
  class App < Roda
    route('restaurants') do |routing|
      routing.on do
        # GET /restaurants/
        routing.get do
          if @current_account.logged_in?
            restaurant_list = GetAllRestaurants.new(App.config).call(@current_account)

            restaurants = Restaurants.new(restaurant_list)

            view :restaurants_all,
                 locals: { current_user: @current_account, restaurants: restaurants }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
