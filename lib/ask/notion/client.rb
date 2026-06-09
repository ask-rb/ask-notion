# frozen_string_literal: true

require "notion-ruby-client"
require "ask/auth"

module Ask
  module Notion
    # Returns an authenticated Notion API client configured for an AI agent.
    #
    # Resolves the Notion token via +Ask::Auth.resolve(:notion_token)+ and
    # wraps the client in a proxy that converts +Notion::Api::Errors::Unauthorized+
    # into +Ask::Auth::InvalidCredential+.
    #
    # The client inherits default configuration from +Notion::Config+:
    # - +token+: resolved via Ask::Auth
    # - +logger+: default logger
    #
    # @example
    #   client = Ask::Notion.client
    #   client.database_query(database_id: "abc123")
    #
    # @return [::Notion::Client] an authenticated client
    # @raise [Ask::Auth::MissingCredential] if no Notion token is configured
    # @raise [Ask::Auth::InvalidCredential] if the token is rejected (401)
    def self.client
      token = Ask::Auth.resolve(:notion_token)

      ClientProxy.new(::Notion::Client.new(token: token))
    end

    # Proxies method calls to a +::Notion::Client+, converting authentication
    # errors into +Ask::Auth::InvalidCredential+.
    class ClientProxy < BasicObject
      def initialize(client)
        @client = client
      end

      def method_missing(name, ...)
        @client.public_send(name, ...)
      rescue ::Notion::Api::Errors::Unauthorized
        ::Kernel.raise ::Ask::Auth::InvalidCredential, :notion_token
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
