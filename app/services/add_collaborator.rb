# frozen_string_literal: true

# Service to add collaborator to restaurant
class AddCollaborator
    class CollaboratorNotAdded < StandardError; end
  
    def initialize(config)
      @config = config
    end
  
    def api_url
      @config.API_URL
    end
  
    def call(current_account:, collaborator:, restaurant_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put("#{api_url}/restaurants/#{restaurant_id}/collaborators",
                          json: { email: collaborator[:email] })
  
      raise CollaboratorNotAdded unless response.code == 200
    end
  end