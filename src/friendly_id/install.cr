require "./cli"
require "file_utils"

module FriendlyId
  class Install
    def self.run
      timestamp = Time.utc.to_s("%Y%m%d%H%M%S")
      app_path = Dir.current
      migrations_path = File.join(app_path, "db", "migrations")

      # Create migrations directory if it doesn't exist
      FileUtils.mkdir_p(migrations_path)

      filename = File.join(migrations_path, "#{timestamp}_create_friendly_id_slugs.sql")
      File.write(filename, migration_sql)
      puts "✓ Created migration #{filename}"
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
