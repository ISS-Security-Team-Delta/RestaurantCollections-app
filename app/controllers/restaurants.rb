# frozen_string_literal: true

require 'roda'
require_relative '../forms/new_restaurant'

module RestaurantCollections
  # Web controller for Credence API
  class App < Roda
    route('restaurants') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        puts "entered the routing for restaurants"
        
        # GET /restaurants/add
        @addRestaurant_route = '/restaurants/add'
        routing.is 'add' do
          routing.get do
            view :add_restaurant
          end
        end
        
        @restaurants_route = '/restaurants'

        routing.on(String) do |rest_id|
          @restaurant_route = "#{@restaurants_route}/#{rest_id}"

          # GET /restaurants/[rest_id]
          routing.get do
            rest_info = GetRestaurant.new(App.config).call(
              @current_account, rest_id
            )
            restaurant = Restaurant.new(rest_info)

            view :restaurant, locals: {
              current_account: @current_account, restaurant: restaurant
            }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Restaurant not found'
            routing.redirect @restaurants_route
          end

          # POST /restaurants/[rest_id]/collaborators
          routing.post('collaborators') do
            action = routing.params['action']
            collaborator_info = Form::CollaboratorEmail.new.call(routing.params)
            if collaborator_info.failure?
              flash[:error] = Form.validation_errors(collaborator_info)
              routing.halt
            end

            task_list = {
              'add' => { service: AddCollaborator,
                         message: 'Added new collaborator to restaurant' },
              'remove' => { service: RemoveCollaborator,
                            message: 'Removed collaborator from restaurant' }
            }

            task = task_list[action]
            task[:service].new(App.config).call(
              current_account: @current_account,
              collaborator: collaborator_info,
              restaurant_id: rest_id
            )
            flash[:notice] = task[:message]

          rescue StandardError
            flash[:error] = 'Could not find collaborator'
          ensure
            routing.redirect @restaurant_route
          end

          # POST /restaurants/[rest_id]/comments/
          routing.post('comments') do
            comment_data = Form::NewComment.new.call(routing.params)
            if comment_data.failure?
              flash[:error] = Form.message_values(comment_data)
              routing.halt
            end

            CreateNewComment.new(App.config).call(
              current_account: @current_account,
              restaurant_id: rest_id,
              comment_data: comment_data.to_h
            )

            flash[:notice] = 'Your comment was added'
          rescue StandardError => error
            puts error.inspect
            puts error.backtrace
            flash[:error] = 'Could not add comment'
          ensure
            routing.redirect @restaurant_route
          end
        end

        # GET /restaurants/
        routing.get do
          binding.pry
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
          CreateNewRestaurant.new(App.config).call(
            current_account: @current_account,
            restaurant_data: restaurant_data.to_h
          )

          flash[:notice] = 'Add comments and collaborators to your new restaurant'
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
