# encoding: utf-8

module Github

  class Authorizations::App < Authorizations

    # Get-or-create an authorization for a specific app
    #
    # @param [Hash] params
    # @option params [String] client_secret
    #  The 40 character OAuth app client secret associated with the client
    #  ID specified in the URL.
    # @option params [Array] :scopes
    #   Optional array - A list of scopes that this authorization is in.
    # @option params [String] :note
    #   Optional string - A note to remind you what the OAuth token is for.
    # @option params [String] :note_url
    #   Optional string - A URL to remind you what the OAuth token is for.
    #
    # @example
    #   github = Github.new
    #   github.oauth.app.create 'client-id', client_secret: '...'
    #
    # @api public
    def create(*args)
      raise_authentication_error unless authenticated?
      arguments(args, required: [:client_id]) do
        sift Authorizations::VALID_AUTH_PARAM_NAMES
      end

      if client_id
        put_request("/authorizations/clients/#{client_id}", arguments.params)
      else
        raise raise_app_authentication_error
      end
    end

    # Revoke all authorizations for an application
    #
    # @example
    #  github = Github.new basic_auth: "client_id:client_secret"
    #  github.oauth.app.delete 'client-id'
    #
    # Revoke an authorization for an application
    #
    # @example
    #
    #  github = Github.new basic_auth: "client_id:client_secret"
    #  github.oauth.app.delete 'client-id', 'access-token'
    #
    # @api public
    def delete(*args)
      raise_authentication_error unless authenticated?
      params = arguments(args, required: [:client_id]).params

      if client_id
        if access_token = (params.delete('access_token') || args[1])
          delete_request("/applications/#{client_id}/tokens/#{access_token}", params)
        else
          # Revokes all tokens
          delete_request("/applications/#{client_id}/tokens", params)
        end
      else
        raise raise_app_authentication_error
      end
    end
    alias :remove :delete
    alias :revoke :delete

    protected

    def raise_app_authentication_error
      raise ArgumentError, 'To create authorization for the app, ' +
        'you need to provide client_id argument and client_secret parameter'
    end
  end
end
