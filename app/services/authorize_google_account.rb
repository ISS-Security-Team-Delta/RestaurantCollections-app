# frozen_string_literal: true
require 'http'

module RestaurantCollections
   # Returns an authenticated user, or nil
   class AuthorizeGoogleAccount
     # Errors emanating from Google
     class UnauthorizedError < StandardError
       def message
         'Could not login with Google.'
       end
     end

     def initialize(config)
       @config = config
     end

     def call(redirect_uri, code)
       id_token = get_id_token_from_google(redirect_uri, code)
       get_sso_account_from_api(id_token)
     end

     private

     def get_id_token_from_google(redirect_uri, code)
       content = HTTP::URI.form_encode(
                     { client_id: @config.GOOGLE_CLIENT_ID,
                       client_secret: @config.GOOGLE_CLIENT_SECRET,
                       grant_type: 'authorization_code',
                       redirect_uri: redirect_uri,
                       code: code })
       challenge_response =
         HTTP.headers(content_type: 'application/x-www-form-urlencoded')
             .post(@config.GOOGLE_TOKEN_URL,
                   body: content)
       raise UnauthorizedError unless challenge_response.status < 400

       JSON.parse(challenge_response)['id_token']
     end

     def get_sso_account_from_api(id_token)
       signed_sso_info = { id_token: id_token, aud: @config.GOOGLE_CLIENT_ID }
         .then { |sso_info| SignedMessage.sign(sso_info) }

       response = HTTP.post(
         "#{@config.API_URL}/auth/google_sso",
         json: signed_sso_info
       )

       raise UnauthorizedError if response.code >= 400

       account_info = JSON.parse(response)['data']['attributes']

       {
         account: account_info['account'],
         auth_token: account_info['auth_token']
       }
     end
   end
 end
