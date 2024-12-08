require "spec"
require "spectator"
require "db"
require "sqlite3"
require "../src/friendly_id"

require "../src/friendly_id/slugged"
require "../src/friendly_id/history"
require "../src/friendly_id/has_many"

DB_PATH = "sqlite3::memory:"
TestDB.database

Spectator.configure do |config|
  # Set up fresh schema before each test
  config.before_suite do
    TestDB.setup_schema
  end

  config.before_each do
    TestDB.setup_schema
  end
end

module TestDB
  class_property database : DB::Database = DB.open("sqlite3::memory:")

  def self.setup_schema
    database.transaction do |tx|
      database.exec "PRAGMA foreign_keys = ON"

      database.exec "DROP TABLE IF EXISTS friendly_id_slugs"
      database.exec "DROP TABLE IF EXISTS posts"
      database.exec "DROP TABLE IF EXISTS users"

      # Create tables in correct order
      database.exec <<-SQL
        CREATE TABLE users (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL
        );
      SQL

      database.exec <<-SQL
        CREATE TABLE posts (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          user_id INTEGER NOT NULL,
          slug TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        );
      SQL

      database.exec <<-SQL
        CREATE TABLE friendly_id_slugs (
          id INTEGER PRIMARY KEY,
          slug TEXT NOT NULL,
          sluggable_id INTEGER NOT NULL,
          sluggable_type TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
      SQL

      # Insert test data
      database.exec "INSERT INTO users (id, name) VALUES (1, 'Test User')"
      database.exec "INSERT INTO users (id, name) VALUES (999, 'Other User')"
    end
  end

  def self.create_test_user(id : Int64 = 1_i64)
    database.exec "INSERT INTO users (id, name) VALUES (?, ?)", id, "Test User #{id}"
  end
end

Spectator.configure do |config|
  config.before_each do
    TestDB.setup_schema
  end
end

# models/post.cr
class Post
  include FriendlyId::Slugged
  include FriendlyId::History

  property id : Int64?
  property title : String
  property body : String
  property user_id : Int64
  property slug : String?

  def initialize(@title : String, @body : String, @user_id : Int64)
  end

  def save
    generate_slug
    TestDB.database.exec "INSERT INTO posts (title, body, user_id, slug) VALUES (?, ?, ?, ?)",
      @title, @body, @user_id, @slug
    @id = TestDB.database.scalar("SELECT last_insert_rowid()").as(Int64)
  end

  def self.create(title : String, body : String, user_id : Int64) : Post
    post = new(title, body, user_id)
    post.save
    post
  end

  def update!(title : String)
    old_slug = @slug
    @title = title
    generate_slug

    TestDB.database.exec "UPDATE posts SET title = ?, slug = ? WHERE id = ?",
      @title, @slug, @id

    TestDB.database.exec "INSERT INTO friendly_id_slugs (slug, sluggable_id, sluggable_type) VALUES (?, ?, ?)",
      old_slug, @id, "Post" if old_slug != @slug
  end

  def slug_history
    results = [] of String
    TestDB.database.query("SELECT slug FROM friendly_id_slugs WHERE sluggable_id = ?", @id) do |rs|
      rs.each do
        results << rs.read(String)
      end
    end
    results
  end

  private def generate_slug
    @slug = @title.downcase.gsub(/[^a-z0-9]+/, "-").chomp("-")
  end
end
