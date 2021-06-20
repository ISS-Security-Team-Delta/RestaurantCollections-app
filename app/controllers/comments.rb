# frozen_string_literal: true

require 'roda'
require_relative './app'

module RestaurantCollections
  # Web controller for RestaurantCollections API
  class App < Roda
    route('comments') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      # GET /comments/[com_id]
      routing.get(String) do |com_id|
        com_info = GetComment.new(App.config)
                              .call(@current_account, com_id)
        comment = Comment.new(com_info)

        view :comment, locals: {
          current_account: @current_account, comment: comment
        }
      end
    end
  end
end