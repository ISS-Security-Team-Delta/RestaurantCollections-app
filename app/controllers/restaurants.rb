# frozen_string_literal: true

require 'roda'
require_relative '../forms/new_restaurant'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class App < Roda
    route('restaurants') do |routing|
      routing.on do
        puts "entered the routing for restaurants"
        # GET /restaurants/
        @addRestaurant_route = '/restaurants/add'
          routing.is 'add' do
          routing.get do
              view :add_restaurant
          end
        end

        @restaurants_route = '/restaurants'
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

        # POST /restaurants/
        routing.post do
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "REST: #{routing.params}"
          restaurant_data = Form::NewRestaurant.new.call(routing.params)
          if restaurant_data.failure?
            flash[:error] = Form.message_values(restaurant_data)
            routing.halt
          end
          puts "Calling restaurant service"
          CreateRestaurant.new(App.config).call(
            current_account: @current_account,
            restaurant_data: restaurant_data.to_h
          )
        rescue StandardError => e
          puts "FAILURE Creating Restaurant: #{e.inspect}"
          flash[:error] = 'Could not create restaurant'
        ensure
          routing.redirect @restaurants_route
        end
      end
    end
  end
end
