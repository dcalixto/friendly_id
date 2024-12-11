# FriendlyId

A Crystal shard for creating human-readable URLs and slugs. FriendlyId lets you create pretty URLs and slugs for your resources, with support for history tracking and customization.

[![Crystal Test](https://github.com/dcalixto/friendly_id/actions/workflows/crystal-test.yml/badge.svg?branch=master)](https://github.com/dcalixto/friendly_id/actions/workflows/crystal-test.yml)

[![Commits](https://img.shields.io/github/commit-activity/y/dcalixto/friendly_id.svg?label=Commits&colorA=004d99&colorB=0073e6)](https://github.com/dcalixto/friendly_id/commits/master/)

[![Downloads](https://img.shields.io/gem/dt/friendly_id.svg?label=Downloads&colorA=004d99&colorB=0073e6)](https://github.com/traffic/clones/total?dcalixto=&friendly_id=&type=count&label=clones-total)

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  friendly_id:
    github: dcalixto/friendly_id
```

> [!NOTE]
> Make sure your database table has a slug column:

```yaml
ALTER TABLE posts ADD COLUMN slug VARCHAR;
```

2. Run

```yaml
shards install
```

Generate and run the required migrations:

```crystal
crystal ../friendly_id/src/friendly_id/install.cr
```

This will create the necessary database tables and indexes for FriendlyId to work:

```crystal
CREATE TABLE friendly_id_slugs (
  id BIGSERIAL PRIMARY KEY,
  slug VARCHAR NOT NULL,
  sluggable_id BIGINT NOT NULL,
  sluggable_type VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Setup

Configure FriendlyId in your application:

> [!NOTE]
> set a initializer # friendly_id.cr

```crystal
require "friendly_id"
FriendlyId.configure do |config|
config.migration_dir = "db/migrations"
end
```

Update your model's save method to include the `generate_slug` method:

```crystal

class Post
  include FriendlyId::Slugged
  friendly_id :title
  # Model-level slug generation
  def save
  generate_slug  # Generate the slug before saving
    @updated_at = Time.utc

    if id
      @@db.exec <<-SQL, title, slug, body, user_id, created_at, updated_at, id
        UPDATE posts
        SET title = ?, slug = ?, body = ?, user_id = ?, created_at = ?, updated_at = ?
        WHERE id = ?
      SQL
    else
      @@db.exec <<-SQL, title, slug, body, user_id, created_at, updated_at
        INSERT INTO posts (title, slug, body, user_id, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?)
      SQL
    end
    self
  end
end

```

Or Update your controller save method to include the `generate_slug` method:

```crystal
class PostsController
  def create(env)
    title = env.params.body["title"]
    body = env.params.body["body"]
    user_id = current_user(env).id

    post = Post.new(
      title: title,
      body: body,
      user_id: user_id
    )

    # Controller-level slug generation
    post.generate_slug # Generate the slug before saving

    if post.save
      env.redirect "/posts/#{post.slug}"
    else
      env.redirect "/posts/new"
    end
  end
end
```

## Usage

Basic Slugging

```crystal
class Post
  include FriendlyId::Slugged
  include FriendlyId::Finders

  property id : Int64?
  property title : String
  property slug : String?
end

post = Post.new("Hello World!")
post.slug # => "hello-world"
```

The Slug is Update Automatically

```crystal
post = Post.new("Hello World!")
post.save
puts post.slug # => "hello-world"

post.title = "Updated Title"
post.save
puts post.slug # => "updated-title"

```

With History Tracking

```crystal
class Post
  include FriendlyId::Slugged
  include FriendlyId::History

  property id : Int64?
  property title : String
  property slug : String?

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

```crystal
class User
  include FriendlyId::Slugged

  property id : Int64?
  property name : String
  property slug : String?
  friendly_id :name  # Use name instead of title for slugs

  def initialize(@name); end
end

user = User.new("John Doe")
user.save
puts user.slug # => "john-doe"
```

## Friendly ID Support

The `FriendlyId::Finders` module provides smart URL slug handling with ID and Historical Slug fallback:

### lookup records by:

- Current slug
- Numeric ID
- Historical slugs

```crystal
class Post
  include FriendlyId::Finders
end

```

Finding Records

```crystal
# All these will work:
Post.find_by_friendly_id("my-awesome-post")  # Current slug
Post.find_by_friendly_id("123")              # ID
Post.find_by_friendly_id("old-post-slug")    # Historical slug
# Regular find still works
post = Post.find(1)
```

## Configuration

```crystal
def should_generate_new_friendly_id?
  title_changed? || slug.nil?
end
```

```crystal
class Post
  include DB::Serializable
  include FriendlyId::Slugged
  include FriendlyId::Finders
  include FriendlyId::History

  # ... your existing code ...

  def should_generate_new_friendly_id?
    title_changed? || slug.nil?
  end
end
```

### Custom Slug Generation

```crystal
class Post
  include FriendlyId::Slugged
   def normalize_friendly_id(value)
   value.downcase.gsub(/\s+/, "-")
  end
end
```

## URL Helpers

To use friendly URLs in your controller, include the `FriendlyId::UrlHelper` module:

```crystal
# In your Controller
include FriendlyId::UrlHelper
```

```crystal
<a href="/posts/<%= friendly_path(post) %>">
  <%= post.title %>
</a>
```

## Features

- Slug generation from specified fields
- SEO-friendly URL formatting
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

```

```
