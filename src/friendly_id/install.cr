require "./cli"
require "file_utils"

module FriendlyId
  class Install
    def self.run
      puts "Install script started"
      timestamp = Time.utc.to_s("%Y%m%d%H%M%S")

      # Get both paths
      shard_root = File.expand_path("../../..", __DIR__).chomp("/lib/friendly_id")
      kemal_root = ENV["KEMAL_APP"]? || Dir.current

      # Create migrations in both locations
      [shard_root, kemal_root].each do |root|
        migrations_path = File.join(root, "db", "migrations")

        next unless Dir.exists?(root)

        begin
          FileUtils.mkdir_p(migrations_path)
          filename = File.join(migrations_path, "#{timestamp}_create_friendly_id_slugs.sql")
          File.write(filename, migration_sql)
          puts "✓ Created migration in: #{filename}"
        rescue ex : Exception
          puts "❌ Error for path #{root}: #{ex.message}"
        end
      end
    end

    private class_getter migration_sql : String = <<-SQL
    CREATE TABLE friendly_id_slugs (
      id BIGSERIAL PRIMARY KEY,
      slug VARCHAR NOT NULL,
      sluggable_id BIGINT NOT NULL,
      sluggable_type VARCHAR(50) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX index_friendly_id_slugs_on_sluggable
    ON friendly_id_slugs (sluggable_type, sluggable_id);
    SQL
  end
end

FriendlyId::Install.run
