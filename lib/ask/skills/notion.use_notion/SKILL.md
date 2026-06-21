---
name: notion.use_notion
description: How to navigate the Notion API with notion-ruby-client — discover endpoints, handle auth, pagination, and errors
---

Use this skill when you need to interact with Notion — reading/writing pages and
databases, managing blocks, searching, or updating properties.

## Step 1: Get the Client

```ruby
client = Ask::Notion.client
```

This returns an authenticated `Notion::Client`. It expects a valid Notion
Internal Integration Token resolved via `Ask::Auth.resolve(:notion_token)`.

If you get an auth error, read `Ask::Notion::Context::AUTH_HOW` for token setup.

## Step 2: Explore the Context

The gem ships with structured context you should reference:

```ruby
Ask::Notion::Context::DOCS_URL     # Notion developer docs
Ask::Notion::Context::API_REF_URL  # Notion API reference
Ask::Notion::Context::GEM_DOCS     # notion-ruby-client docs
Ask::Notion::Context::QUICK_START  # Copy-paste examples
```

The `QUICK_START` constant has examples for database queries, page CRUD, block
children, and search.

## Step 3: Discover Available Methods

Use code tools to explore the available client methods:

```ruby
Code.new.call(code: "
  client = Ask::Notion.client
  puts client.methods(false).sort.join(\"\\n\")
")
```

Common Notion API calls:
- `client.database_query(database_id:, filter:, sorts:)` — query a database
- `client.database_retrieve(database_id:)` — get database schema
- `client.page_retrieve(page_id:)` — read a page
- `client.page_create(parent:, properties:)` — create a page
- `client.page_update(page_id:, properties:)` — update page properties
- `client.block_children_list(block_id:)` — list page blocks
- `client.append_block_children(block_id:, children:)` — add blocks
- `client.search(query:)` — search across pages and databases

For method details, read the client source:
```ruby
Grep.new.call(pattern: "def database_query", path: "$GEM_PATH/notion-ruby-client-*/lib")
```

## Step 4: Property Formatting (Most Common Pitfall)

Notion properties are complex. Before creating or updating, always check the
database schema first:

```ruby
db = client.database_retrieve(database_id: "YOUR_DB_ID")
db.properties.each do |name, prop|
  puts "#{name}: #{prop.type}"
end
```

Property values follow this format pattern:
```ruby
{
  "Name": { title: [{ text: { content: "Page Title" } }] },
  "Status": { status: { name: "Done" } },
  "Date": { date: { start: "2026-01-01" } },
  "Select": { select: { name: "Option" } },
  "Multi-select": { multi_select: [{ name: "Tag1" }] },
  "Number": { number: 42 },
  "Checkbox": { checkbox: true },
  "Email": { email: "user@example.com" },
  "URL": { url: "https://example.com" },
  "Relation": { relation: [{ id: "RELATED_PAGE_ID" }] }
}
```

The `notion-ruby-client` gem does minimal conversion — you pass raw hashes.
For reference, see `Ask::Notion::Context::API_REF_URL`.

## Step 5: Authentication & Common Errors

For detailed error guidance, use:

```ruby
Ask::Notion::Errors.for("Notion::Api::Errors::Forbidden")
Ask::Notion::Errors.status_code_description(403)
Ask::Notion::Errors::PAGINATION
```

Common scenarios:
- **403 Forbidden**: Integration hasn't been shared with the page/database →
  click "Share" in Notion and add your integration by name
- **404 Not Found**: Wrong ID or not shared → verify the page ID and sharing
- **400 Bad Request**: Property values have wrong types → check the schema first
- **429 Too Many Requests**: Rate limited (3 req/s burst, 90 req/min)

## Step 6: Pagination

Notion uses cursor-based pagination. The `notion-ruby-client` gem accepts
a block to auto-paginate:

```ruby
client.database_query(database_id: "DB_ID") do |page|
  puts page.results.map { |r| r.id }
end
```

Or manual pagination:
```ruby
response = client.database_query(database_id: "DB_ID", start_cursor: cursor, page_size: 100)
cursor = response.next_cursor
# Pass cursor as start_cursor in next request
```

## Step 7: Fallback Strategy

If the client doesn't have a method for what you need:
1. Check `Ask::Notion::Context::DOCS_URL` for the API endpoint
2. Notion's API is a REST API — you can use Faraday for any endpoint
3. Use `client.request(method:, path:, body:)` for custom requests
