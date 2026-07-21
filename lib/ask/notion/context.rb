# frozen_string_literal: true

module Ask
  module Notion
    # Human-readable description of the Notion service context.
    DESCRIPTION = "Notion — pages, databases, blocks, comments, users, search"

    # Base URL for Notion API documentation.
    DOCS_URL = "https://developers.notion.com/"

    # URL for the Notion API reference.
    API_REF_URL = "https://developers.notion.com/reference"

    # Notion no longer serves an OpenAPI spec at a stable URL.
    # The API reference is at API_REF_URL instead.
    # OPENAPI_URL was removed because the spec is no longer available.

    # Credential name used with Ask::Auth.resolve.
    AUTH_NAME = :notion_token

    # Instructions for obtaining a Notion Internal Integration Token.
    AUTH_HOW = "https://www.notion.so/my-integrations — create an integration and copy the 'Internal Integration Secret' (starts with 'ntn_' or 'secret_')"

    # Gem name for the Notion API client.
    GEM_NAME = "notion-ruby-client"

    # Required gem version constraint.
    GEM_VERSION = "~> 1.2"

    # URL for notion-ruby-client library documentation.
    GEM_DOCS = "https://www.rubydoc.info/gems/notion-ruby-client"

    # Quick-start Ruby code snippet for agents to copy-paste.
    QUICK_START = <<~RUBY
      client = Ask::Notion.client
      client.database_query(database_id: "DB_ID")
      client.page_retrieve(page_id: "PAGE_ID")
      client.page_create(parent: { database_id: "DB_ID" }, properties: { "Name": { title: [{ text: { content: "New Page" } }] } })
      client.page_update(page_id: "PAGE_ID", properties: { "Status": { status: { name: "Done" } } })
      client.block_children_list(block_id: "BLOCK_ID")
      client.append_block_children(block_id: "BLOCK_ID", children: [{ paragraph: { rich_text: [{ text: { content: "Hello!" } }] } }])
      client.search(query: "project")
    RUBY
  end
end
