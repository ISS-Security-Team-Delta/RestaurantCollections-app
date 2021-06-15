# frozen_string_literal: true

require 'http'

# Returns all restaurants belonging to an account
class GetComment
  def initialize(config)
    @config = config
  end

  def call(user, com_id)
    response = HTTP.auth("Bearer #{user.auth_token}")
                   .get("#{@config.API_URL}/comments/#{com_id}")

    response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
  end
end