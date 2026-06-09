# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
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

    # Check that the token was passed via the underlying client's config
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
end
