# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative '../forms/auth'

module RestaurantCollections
  # Web controller for Restaurant Collections APP
  class App < Roda
    def gh_oauth_url(config)
      url = config.GH_OAUTH_URL
      client_id = config.GH_CLIENT_ID
      scope = config.GH_SCOPE

      "#{url}?client_id=#{client_id}&scope=#{scope}"
    end

    def google_oauth_url(config, callback_url)
      url = config.GOOGLE_OAUTH_URL
      client_id = config.GOOGLE_CLIENT_ID
      scope = config.GOOGLE_SCOPE

      "#{url}?client_id=#{client_id}&scope=#{scope}&response_type=code&access_type=offline&include_granted_scopes=true&redirect_uri=#{callback_url}"
    end


    route('auth') do |routing|
      @oauth_callback = '/auth/sso_callback'
      @google_callback_uri = "#{App.config.APP_URL}/auth/google_sso_callback"
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login, locals: {
            gh_oauth_url: gh_oauth_url(App.config),
            google_oauth_url: google_oauth_url(App.config, @google_callback_uri)
          }
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.new.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new.call(**credentials.values)

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/restaurants'
        rescue AuthenticateAccount::NotAuthenticatedError
          flash[:error] = 'Username and password did not match our records'
          response.status = 401
          routing.redirect @login_route
        rescue AuthenticateAccount::ApiServerError => e
          puts "LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      # Github
      routing.is 'sso_callback' do
        # GET /auth/sso_callback
        routing.get do
          authorized = AuthorizeGithubAccount
                       .new(App.config)
                       .call(routing.params['code'])

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.username}!"
          routing.redirect '/restaurants'
        rescue AuthorizeGithubAccount::UnauthorizedError
          flash[:error] = 'Could not login with Github'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end

      # Google
      routing.is 'google_sso_callback' do
        # GET /auth/google_sso_callback
        routing.get do
          authorized = AuthorizeGoogleAccount
                       .new(App.config)
                       .call(@google_callback_uri, routing.params['code'])

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome #{current_account.username}!"
          routing.redirect '/restaurants'
        rescue AuthorizeGoogleAccount::UnauthorizedError
          flash[:error] = 'Could not login with Google'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "GOOGLE SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end


      # GET /auth/logout
      @logout_route = '/auth/logout'
      routing.is 'logout' do
        routing.get do
          CurrentSession.new(session).delete
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.new.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            account_data = JsonRequestBody.symbolize(routing.params)
            VerifyRegistration.new(App.config).call(account_data)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue StandardError => e
            puts "ERROR VERIFYING REGISTRATION: #{routing.params}\n#{e.inspect}"
            flash[:error] = 'Please use English characters for username only'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          new_account = SecureMessage.decrypt(registration_token)
          view :register_confirm,
               locals: { new_account: new_account,
                         registration_token: registration_token }
        end
      end

      @resetpwd_route = '/auth/resetpwd'
      routing.on 'resetpwd' do
        routing.is do
          routing.get do
            view :resetpwd
          end
          # POST /auth/resetpwd
          routing.post do
            resetpwd = Form::ResetPwd.new.call(routing.params)

            if resetpwd.failure?
              flash[:error] = Form.validation_errors(resetpwd)
              routing.redirect @resetpwd_route
            end
            account_data = JsonRequestBody.symbolize(routing.params)
            VerifyResetPassword.new(App.config).call(resetpwd.to_h)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue VerifyResetPassword::VerificationError => e
            flash[:error] = e.message
            routing.redirect @resetpwd_route
          rescue StandardError => e
            puts "ERROR VERIFYING RESET PWD: #{routing.params}\n#{e.inspect}"
            flash[:error] = 'Please use a valid email address.'
            routing.redirect @resetpwd_route
          end
        end

        # GET /auth/resetpwd/<token>
        routing.get(String) do |resetpwd_token|
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          account = SecureMessage.decrypt(resetpwd_token)

          action_route = "/account/resetpwd/#{resetpwd_token}"

          view :resetpwd_confirm, locals: { account: account,
                                           action_route: action_route}
        end
      end
    end
  end
end
