# FriendlyId

A Crystal shard for creating human-readable URLs and slugs. FriendlyId lets you create pretty URLs and slugs for your resources, with support for history tracking and customization.

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

## Setup

Configure FriendlyId in your application:

> [!NOTE]
> set a initializer # friendly_id.cr

```yaml
require "friendly_id"

FriendlyId.configure do |config|
config.migration_dir = "db/migrations"
end
```

Update your model's save method to include the `generate_slug` method:

```yaml

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

```yaml
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

```yaml
class Post
  include FriendlyId::Slugged

  property title : String


end

post = Post.new("Hello World!")
post.slug # => "hello-world"
```

The Slug is Update Automatically

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

> [!CAUTION]
> Still with issues need to fix FriendlyId::History

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
  friendly_id :name  # Use name instead of title for slugs

  def initialize(@name); end
end

user = User.new("John Doe")
user.save
puts user.slug # => "john-doe"
```

## Friendly ID Support

The `FriendlyId::Finders` module provides smart URL slug handling with ID fallback:

```crystal
class Post
  include FriendlyId::Finders
end

```

Finding Records

```yaml
# Will find post by either slug or id
Post.find_by_friendly_id("my-awesome-post")
Post.find_by_friendly_id("25")
```

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
