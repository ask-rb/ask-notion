# frozen_string_literal: true

require_relative "test_helper"

class ErrorGuideTest < Minitest::Test
  def test_rate_limit_burst
    assert_includes Ask::Notion::Errors::RATE_LIMIT[:burst], "3"
  end

  def test_rate_limit_sustained
    assert_includes Ask::Notion::Errors::RATE_LIMIT[:sustained], "90"
  end

  def test_rate_limit_has_error_class
    assert_equal "Notion::Api::Errors::TooManyRequests", Ask::Notion::Errors::RATE_LIMIT[:error_class]
  end

  def test_status_codes_cover_common_codes
    [200, 201, 204, 400, 401, 403, 404, 409, 412, 429, 500, 502, 503].each do |code|
      assert Ask::Notion::Errors::STATUS_CODES.key?(code), "Missing status code #{code}"
    end
  end

  def test_status_code_description_returns_string
    desc = Ask::Notion::Errors.status_code_description(404)
    assert_match(/Not Found/, desc)
  end

  def test_status_code_description_returns_nil_for_unknown
    assert_nil Ask::Notion::Errors.status_code_description(999)
  end

  def test_exceptions_cover_common_errors
    %w[
      Notion::Api::Errors::Unauthorized
      Notion::Api::Errors::Forbidden
      Notion::Api::Errors::ObjectNotFound
      Notion::Api::Errors::TooManyRequests
      Notion::Api::Errors::BadRequest
      Notion::Api::Errors::InvalidRequest
      Notion::Api::Errors::UnavailableError
      Notion::Api::Errors::TimeoutError
      Notion::Api::Errors::ServerError
    ].each do |klass|
      assert Ask::Notion::Errors::EXCEPTIONS.key?(klass), "Missing exception #{klass}"
    end
  end

  def test_for_returns_guidance
    guidance = Ask::Notion::Errors.for("Notion::Api::Errors::ObjectNotFound")
    assert guidance.key?(:message)
    assert guidance.key?(:action)
  end

  def test_for_returns_nil_for_unknown
    assert_nil Ask::Notion::Errors.for("Some::Unknown::Error")
  end

  def test_exception_messages_are_helpful
    error = Ask::Notion::Errors.for("Notion::Api::Errors::Unauthorized")
    assert_includes error[:action], "www.notion.so/my-integrations"
  end

  def test_pagination_info_is_defined
    assert Ask::Notion::Errors::PAGINATION.key?(:cursor_based)
    assert Ask::Notion::Errors::PAGINATION.key?(:page_size)
    assert Ask::Notion::Errors::PAGINATION.key?(:next_cursor)
    assert Ask::Notion::Errors::PAGINATION.key?(:has_more)
  end
end
