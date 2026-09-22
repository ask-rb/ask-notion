# ask-notion

[![Gem Version](https://badge.fury.io/rb/ask-notion.svg)](https://badge.fury.io/rb/ask-notion)

> **⚠️ DEPRECATED:** This gem is deprecated. Use Notion's official MCP server
> instead. Existing installations of this gem may continue to work, but this
> repository will receive no further feature development.

Notion service context for AI agents in the ask-rb ecosystem. It provides an
authenticated Notion API client built on notion-ruby-client, metadata
constants for system prompts, and a structured error guide for common Notion
API issues.

## Installation

```ruby
gem "ask-notion"
```

## Quick Start

```ruby
require "ask-notion"

client = Ask::Notion.client

# Query a database
results = client.database_query(database_id: "DB_ID")

# Get a page
page = client.page_retrieve(page_id: "PAGE_ID")

# Create a page in a database
client.page_create(
  parent: { database_id: "DB_ID" },
  properties: { "Name" => { title: [{ text: { content: "New Page" } }] } }
)

# Search across Notion
client.search(query: "project")

# List blocks in a page and list workspace users
client.block_children_list(block_id: "BLOCK_ID")
client.user_list
```

## Authentication

`Ask::Notion.client` resolves a token via `Ask::Auth.resolve(:notion_token)`.
Set it in your environment:

```bash
export NOTION_TOKEN=ntn_your_integration_token
```

Or add it to `~/.ask/credentials.yml`:

```yaml
notion_token: ntn_your_integration_token
```

Credentials can also come from Rails credentials, a database, or an OAuth
provider, depending on your `ask-auth` configuration. Create an integration at
[notion.so/my-integrations](https://www.notion.so/my-integrations) and copy
the Internal Integration Secret.

## Key entry points

- `Ask::Notion.client` - an authenticated `Notion::Client`. It is wrapped in a
  proxy that converts `Notion::Api::Errors::Unauthorized` into
  `Ask::Auth::InvalidCredential` and retries rate limits and transient
  failures with exponential backoff.
- `Ask::Notion::Errors` - structured error knowledge for agents: guidance by
  exception class, HTTP status code descriptions, and rate limit info.
- `Ask::Notion::DESCRIPTION`, `DOCS_URL`, `AUTH_NAME`, `GEM_NAME`,
  `GEM_VERSION`, and `QUICK_START` - metadata constants for system prompts.

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs.
[Services: Notion](https://ask-rb.github.io/ask-docs/services/notion) covers
ask-notion in depth, including the client, error guide, and constants.
API reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

```
bundle install
bundle exec rake test
```

## License

MIT
