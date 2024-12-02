require "./cli"
require "file_utils"
require "db"
require "sqlite3"

module FriendlyId
  class Install
    def self.run
      timestamp = Time.utc.to_s("%Y%m%d%H%M%S")
      filename = "db/migrations/#{timestamp}_create_friendly_id_slugs.sql"

      # Create migration file
      File.write(filename, migration_sql)
      puts "✓ Created migration #{filename}"

      # Execute migration
      DB.open "sqlite3:./db/application.db" do |db|
        db.exec migration_sql
      end
      puts "✓ Executed migration - friendly_id_slugs table created"
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
