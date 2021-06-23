# frozen_string_literal: true

require_relative 'form_base'

module RestaurantCollections
  module Form
    class NewComment < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_comment.yml')

      params do
        required(:content).filled
        required(:like).filled.value(:integer)
      end
    end
  end
end