# frozen_string_literal: true

require "notion-ruby-client"
require "ask/auth"

module Ask
  module Notion
    # Default number of retries for transient failures.
    DEFAULT_RETRIES = 3

    # Returns an authenticated Notion API client configured for an AI agent.
    #
    # Resolves the Notion token via +Ask::Auth.resolve(:notion_token)+ and
    # wraps the client in a proxy that converts authentication, timeout, and
    # network errors into ask-rb equivalents.
    #
    # The client inherits default configuration from +Notion::Config+:
    # - +token+: resolved via Ask::Auth
    # - +logger+: default logger
    #
    # Retries transient failures (rate limits, server errors) up to
    # {DEFAULT_RETRIES} times with exponential backoff.
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

    # Proxies method calls to a +::Notion::Client+, converting authentication,
    # timeout, and network errors into ask-rb exceptions with automatic retry
    # for transient failures.
    class ClientProxy < BasicObject
      def initialize(client)
        @client = client
      end

      def method_missing(name, ...)
        retries = 0
        begin
          @client.public_send(name, ...)
        rescue ::Notion::Api::Errors::Unauthorized
          ::Kernel.raise ::Ask::Auth::InvalidCredential, :notion_token
        rescue ::Notion::Api::Errors::TooManyRequests,
               ::Notion::Api::Errors::UnavailableError,
               ::Notion::Api::Errors::ServerError,
               ::Timeout::Error,
               ::Errno::ECONNREFUSED,
               ::Errno::ECONNRESET
          retries += 1
          if retries <= ::Ask::Notion::DEFAULT_RETRIES
            ::Kernel.sleep(2 ** retries * 0.1)
            retry
          end
          ::Kernel.raise
        end
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
