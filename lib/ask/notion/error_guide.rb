# frozen_string_literal: true

module Ask
  module Notion
    # Structured error knowledge for AI agents working with the Notion API.
    #
    # Provides human-readable guidance for common HTTP status codes, rate
    # limiting, pagination, and authentication errors encountered when
    # using the Notion API via the notion-ruby-client gem.
    module Errors
      # Rate limit information.
      #
      # - Authenticated requests: 3 requests per second (burst), 90 requests per minute
      #
      # When rate-limited, the API returns 429 and raises
      # +Notion::Api::Errors::TooManyRequests+. The agent should respect the
      # Retry-After header and back off.
      RATE_LIMIT = {
        burst: "3 requests per second (per integration)",
        sustained: "90 requests per minute (per integration)",
        error_class: "Notion::Api::Errors::TooManyRequests",
        action: "Respect the Retry-After header and wait before retrying. Use exponential backoff."
      }.freeze

      # Common HTTP status codes returned by the Notion API and how to handle them.
      STATUS_CODES = {
        200 => "OK — Request succeeded.",
        201 => "Created — Resource was created successfully.",
        204 => "No Content — Request succeeded, no response body.",
        400 => "Bad Request — Request body is malformed. Check JSON structure and field types.",
        401 => "Unauthorized — Integration token is missing, invalid, or revoked. Re-authenticate at https://www.notion.so/my-integrations.",
        403 => "Forbidden — Integration lacks access to the requested resource. Share the page or database with the integration in Notion.",
        404 => "Not Found — Resource does not exist or the integration does not have access to it.",
        409 => "Conflict — Resource state conflict. The resource may have been updated by another request.",
        412 => "Precondition Failed — Use the correct Notion-Version header (e.g., '2022-06-28').",
        429 => "Too Many Requests — Rate limit exceeded. Respect Retry-After header.",
        500 => "Internal Server Error — Notion server issue. Retry with backoff.",
        502 => "Bad Gateway — Notion upstream issue. Retry with backoff.",
        503 => "Service Unavailable — Notion is down for maintenance. Retry later."
      }.freeze

      # Pagination guidance for large result sets.
      PAGINATION = {
        cursor_based: "Notion uses cursor-based pagination. Supply a block to the client method to auto-paginate.",
        page_size: "Maximum items per page is 100. The client uses this as the default.",
        next_cursor: "Responses include a next_cursor key. Pass it as start_cursor in the next request.",
        has_more: "Responses include a has_more boolean. When false, all results have been retrieved."
      }.freeze

      # Map of Notion exception classes to human-readable guidance.
      EXCEPTIONS = {
        "Notion::Api::Errors::Unauthorized" => {
          message: "Your Notion integration token is invalid or has been revoked.",
          action: "Generate a new token at https://www.notion.so/my-integrations. Tokens start with 'ntn_' or 'secret_'."
        },
        "Notion::Api::Errors::Forbidden" => {
          message: "Your integration does not have access to this page or database.",
          action: "In Notion, click 'Share' on the page/database and add your integration by name."
        },
        "Notion::Api::Errors::ObjectNotFound" => {
          message: "The requested page, database, or block does not exist or is not shared with the integration.",
          action: "Verify the ID is correct and that the resource is shared with your integration."
        },
        "Notion::Api::Errors::TooManyRequests" => {
          message: "Notion API rate limit exceeded.",
          action: "Check the Retry-After header, wait that many seconds, then retry. Limit: 3 req/s burst, 90 req/min sustained."
        },
        "Notion::Api::Errors::BadRequest" => {
          message: "The request body is invalid or missing required fields.",
          action: "Check the JSON structure, field names, and value types against the API reference at https://developers.notion.com/reference."
        },
        "Notion::Api::Errors::InvalidRequest" => {
          message: "The request body failed validation against the Notion API schema.",
          action: "Check required fields, property types, and data formats. Notion returns detailed error messages."
        },
        "Notion::Api::Errors::UnavailableError" => {
          message: "Notion is temporarily unavailable or down for maintenance.",
          action: "Retry with exponential backoff. If the issue persists, check https://status.notion.com."
        },
        "Notion::Api::Errors::TimeoutError" => {
          message: "The request timed out.",
          action: "Retry with exponential backoff. The Notion API may be experiencing high latency."
        },
        "Notion::Api::Errors::ParsingError" => {
          message: "Failed to parse the Notion API response.",
          action: "Retry the request. This is usually a transient issue."
        },
        "Notion::Api::Errors::ServerError" => {
          message: "Notion encountered a server error.",
          action: "Retry with exponential backoff. If the issue persists, check https://status.notion.com."
        }
      }.freeze

      # Look up guidance for an exception class name.
      #
      # @param exception_class [String] The exception class name (e.g., "Notion::Api::Errors::ObjectNotFound")
      # @return [Hash, nil] A hash with +:message+ and +:action+ keys, or nil if unknown
      def self.for(exception_class)
        EXCEPTIONS[exception_class]
      end

      # Describe an HTTP status code.
      #
      # @param code [Integer] HTTP status code
      # @return [String, nil] Description of the status code
      def self.status_code_description(code)
        STATUS_CODES[code]
      end
    end
  end
end
