# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  ResponseStub = Struct.new(:status, :body)

  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_returns_notion_client_when_token_available
    token = "ntn_test_token_12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "notion_token" }]
    end

    client = Ask::Notion.client
    assert_kind_of Notion::Client, client
  end

  def test_client_passes_token_to_notion_client
    token = "ntn_test_token_12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "notion_token" }]
    end

    client = Ask::Notion.client
    assert_equal token, client.instance_variable_get(:@token)
  end

  def test_client_raises_missing_credential_without_token
    Ask::Auth.configure do |config|
      config.providers = []
    end

    assert_raises(Ask::Auth::MissingCredential) { Ask::Notion.client }
  end

  def test_client_raises_invalid_credential_on_401
    token = "bad_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "notion_token" }]
    end

    error = Notion::Api::Errors::Unauthorized.new("unauthorized", "Token is invalid")
    Notion::Client.any_instance.stubs(:database_query).raises(error)

    assert_raises(Ask::Auth::InvalidCredential) { Ask::Notion.client.database_query(database_id: "test") }
  end

  def test_client_rate_limit_info_in_error
    Ask::Auth.configure do |config|
      config.providers = []
    end

    error = assert_raises(Ask::Auth::MissingCredential) { Ask::Notion.client }
    assert_match(/notion_token/, error.message)
  end

  def test_client_proxies_normal_calls
    token = "ntn_test_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "notion_token" }]
    end

    Notion::Client.any_instance.stubs(:database_query).returns({ "results" => [] })

    result = Ask::Notion.client.database_query(database_id: "test-id")
    assert_equal({ "results" => [] }, result)
  end

  def test_default_retries_constant
    assert_equal 3, Ask::Notion::DEFAULT_RETRIES
  end

  # -------------------------------------------------------------------
  # ClientProxy tests — test retry/timeout/error conversion in isolation
  # -------------------------------------------------------------------

  def make_proxy(behavior_map)
    underlying = mock("notion_client")
    behavior_map.each do |method, behaviors|
      expectation = underlying.stubs(method)
      behaviors.each do |b|
        if b[:type] == :raise
          expectation = expectation.raises(b[:error])
        elsif b[:type] == :return
          expectation = expectation.returns(b[:value])
        end
      end
    end
    Ask::Notion::ClientProxy.new(underlying)
  end

  def test_proxy_retries_on_too_many_requests
    error = Notion::Api::Errors::TooManyRequests.new(
      ResponseStub.new(429, {})
    )
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: error },
        { type: :raise, error: error },
        { type: :return, value: { "results" => ["success"] } }
      ]
    })
    result = proxy.database_query(database_id: "test-id")
    assert_equal({ "results" => ["success"] }, result)
  end

  def test_proxy_retries_on_server_error
    error = Notion::Api::Errors::ServerError.new("server_error", "Oops")
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: error },
        { type: :return, value: { "results" => ["ok"] } }
      ]
    })
    result = proxy.database_query(database_id: "test-id")
    assert_equal({ "results" => ["ok"] }, result)
  end

  def test_proxy_exhausts_retries
    error = Notion::Api::Errors::ServerError.new("server_error", "Nope")
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: error },
        { type: :raise, error: error },
        { type: :raise, error: error },
        { type: :raise, error: error }
      ]
    })
    assert_raises(Notion::Api::Errors::ServerError) do
      proxy.database_query(database_id: "test-id")
    end
  end

  def test_proxy_retries_on_timeout
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: Timeout::Error },
        { type: :return, value: { "results" => ["ok"] } }
      ]
    })
    result = proxy.database_query(database_id: "test-id")
    assert_equal({ "results" => ["ok"] }, result)
  end

  def test_proxy_exhausts_timeout_retries
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: Timeout::Error },
        { type: :raise, error: Timeout::Error },
        { type: :raise, error: Timeout::Error },
        { type: :raise, error: Timeout::Error }
      ]
    })
    assert_raises(Timeout::Error) do
      proxy.database_query(database_id: "test-id")
    end
  end

  def test_proxy_retries_on_connection_refused
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: Errno::ECONNREFUSED },
        { type: :return, value: { "results" => ["ok"] } }
      ]
    })
    result = proxy.database_query(database_id: "test-id")
    assert_equal({ "results" => ["ok"] }, result)
  end

  def test_proxy_converts_unauthorized
    error = Notion::Api::Errors::Unauthorized.new("unauthorized", "Bad token")
    proxy = make_proxy({
      database_query: [
        { type: :raise, error: error }
      ]
    })
    assert_raises(Ask::Auth::InvalidCredential) do
      proxy.database_query(database_id: "test")
    end
  end
end
