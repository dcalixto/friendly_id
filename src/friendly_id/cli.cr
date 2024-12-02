module FriendlyId
  class Install
    def self.run
      timestamp = Time.utc.to_s("%Y%m%d%H%M%S")
      filename = "db/migrations/#{timestamp}_create_friendly_id_slugs.sql"

      File.write(filename, MIGRATION_SQL)
      puts "✓ Created migration #{filename}"
    end

    private MIGRATION_SQL = <<-SQL
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
