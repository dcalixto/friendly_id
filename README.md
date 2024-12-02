# FriendlyId

A Crystal shard for creating human-readable URLs and slugs. FriendlyId lets you create pretty URLs and slugs for your resources, with support for history tracking and customization.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  friendly_id:
    github: dcalixto/friendly_id
```

2. Run

```yaml
shards install
```

## Setup

Configure FriendlyId in your application:

> [!NOTE]
> if your migrations path is diferent than # db/migrations

```yaml
FriendlyId.configure do |config|
  config.migration_dir = "db/migrations" # Default path for migrations
end
```

## Usage

Basic Slugging

```yaml
class Post
  include FriendlyId::Slugged

  property title : String

  def initialize(@title)
  end
end

post = Post.new("Hello World!")
post.slug # => "hello-world"
```

Update the Slug Automatically

```yaml
post = Post.new("Hello World!")
post.save
puts post.slug # => "hello-world"

post.title = "Updated Title"
post.save
puts post.slug # => "updated-title"
puts post.slug_history # => ["hello-world"]
```

With History Tracking

```yaml
class Post
  include FriendlyId::Slugged
  include FriendlyId::History

  property title : String

  def initialize(@title)
  end
end

post = Post.new("Hello World!")
post.save
post.slug # => "hello-world"

post.title = "Updated Title"
post.save
post.slug_history # => ["hello-world"]
```

Using a Custom Attribute

```yaml
class User
  include FriendlyId::Slugged

  property name : String
  FriendlyId::Slugged.set_slug_base("name")

  def initialize(@name); end
end

user = User.new("John Doe")
user.save
puts user.slug # => "john-doe"
```

Finding Records

```yaml

# Find by slug
post = Post.find_by_friendly_id("hello-world")

# Regular find still works
post = Post.find(1)

```

Custom Slug Generation

```yaml
class Post
include FriendlyId::Slugged

def normalize_friendly_id(value)
value.downcase.gsub(/\s+/, "-")
end
end
```

## Features

- Slug generation from model attributes
- History tracking of slug changes
- Custom slug normalization
- Special character handling
- Database-backed slug storage

Run tests

```crystal
crystal spec

```

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Contributors

Daniel Calixto - creator and maintainer

## License

MIT License. See LICENSE for details.
