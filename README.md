# ask-notion

notion service context for the ask-rb ecosystem.

Provides:
- `Ask::notion.client` — authenticated API client
- `Ask::notion.context` — context metadata for the system prompt
- `Ask::notion::Errors` — structured error knowledge for agents

## Installation

```ruby
gem "ask-notion"
```

## Usage

```ruby
client = Ask::notion.client
# ... use the client according to its API
```

## Development

```bash
bin/setup
bundle exec rake test
```

## License

MIT
