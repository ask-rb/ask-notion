# frozen_string_literal: true

require_relative "test_helper"

class ContextTest < Minitest::Test
  def test_description_is_defined
    assert_match(/Notion/, Ask::Notion::DESCRIPTION)
  end

  def test_docs_url_is_defined
    assert Ask::Notion::DOCS_URL.start_with?("https://developers.notion.com")
  end

  def test_api_ref_url_is_defined
    assert Ask::Notion::API_REF_URL.start_with?("https://developers.notion.com")
  end

  def test_openapi_url_is_defined
    assert Ask::Notion::OPENAPI_URL.start_with?("https://developers.notion.com")
  end

  def test_auth_name_is_notion_token
    assert_equal :notion_token, Ask::Notion::AUTH_NAME
  end

  def test_auth_how_is_defined
    assert_includes Ask::Notion::AUTH_HOW, "my-integrations"
  end

  def test_gem_name_is_notion_ruby_client
    assert_equal "notion-ruby-client", Ask::Notion::GEM_NAME
  end

  def test_gem_version_is_defined
    assert_match(/~> 1\.2/, Ask::Notion::GEM_VERSION)
  end

  def test_gem_docs_is_defined
    assert Ask::Notion::GEM_DOCS.start_with?("https://www.rubydoc.info/gems/notion-ruby-client")
  end

  def test_quick_start_is_defined
    assert_includes Ask::Notion::QUICK_START, "Ask::Notion.client"
  end

  def test_quick_start_includes_common_methods
    %w[database_query page_retrieve page_create page_update block_children_list append_block_children search].each do |method|
      assert_includes Ask::Notion::QUICK_START, method
    end
  end
end
