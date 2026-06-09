# ask-notion

Notion service context for the ask-rb ecosystem.

Provides:
- `Ask::Notion.client` — authenticated Notion API client
- `Ask::Notion::DESCRIPTION` — context metadata for the system prompt
- `Ask::Notion::Errors` — structured error knowledge for AI agents

## Installation

```ruby
gem "ask-notion"
```

## Usage

```ruby
require "ask-notion"

# Returns an authenticated Notion::Client
client = Ask::Notion.client

# Query a database
results = client.database_query(database_id: "your-database-id")

# Get a page
page = client.page_retrieve(page_id: "your-page-id")

# Create a page in a database
client.page_create(
  parent: { database_id: "your-database-id" },
  properties: {
    "Name" => { title: [{ text: { content: "New Task" } }] },
    "Status" => { status: { name: "In Progress" } }
  }
)

# Search across Notion
results = client.search(query: "project notes")
```

## Auth Setup

This gem uses `Ask::Auth` to resolve the `:notion_token` credential.

1. Go to https://www.notion.so/my-integrations
2. Create a new integration and copy the Internal Integration Secret
3. Set the token in your environment:

```bash
export NOTION_TOKEN="ntn_your_integration_token"
```

Or add it to `~/.ask/credentials.yml`:

```yaml
notion_token: ntn_your_integration_token
```

## Development

```bash
bin/setup
bundle exec rake test
```

## License

MIT
