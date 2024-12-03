puts "Install script execution started"

require "./cli"
require "file_utils"

module FriendlyId
  class Install
    def self.run
      puts "Install script started"

      timestamp = Time.utc.to_s("%Y%m%d%H%M%S")
      puts "Generated timestamp: #{timestamp}"

      app_root = File.expand_path("../../..", __DIR__).chomp("/lib/friendly_id")
      puts "Calculated app root: #{app_root}"

      migrations_path = File.join(app_root, "db", "migrations")
      puts "Target migrations path: #{migrations_path}"

      unless Dir.exists?(app_root)
        puts "❌ Error: App root directory not found: #{app_root}"
        return
      end

      begin
        FileUtils.mkdir_p(migrations_path)
        puts "✓ Created or confirmed migrations directory: #{migrations_path}"
      rescue ex : Exception
        puts "❌ Error creating migrations directory: #{ex.message}"
        return
      end

      filename = File.join(migrations_path, "#{timestamp}_create_friendly_id_slugs.sql")
      puts "Target filename: #{filename}"

      begin
        File.write(filename, migration_sql)
        puts "✓ Created migration file: #{filename}"
      rescue ex : Exception
        puts "❌ Error writing migration file: #{ex.message}"
        return
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
