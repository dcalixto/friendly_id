module FriendlyId
  module Finders
    # List of all possible script prefixes we use
    SCRIPT_PREFIXES = ["cjk", "cyr", "dev", "ara", "heb", "tha", "gre", "arm", "geo", "oth"]

    macro included
      def self.find_by_friendly_id(id : String)
        # Try to parse as integer first
        id_as_int = id.to_i64? rescue nil

        if id_as_int
          find_by_id(id_as_int)
        elsif SCRIPT_PREFIXES.any? { |prefix| id.starts_with?("#{prefix}-") }
          # This is an encoded non-Latin script slug
          # Extract the prefix and encoded part
          prefix = id.split("-").first
          encoded_part = id.sub("#{prefix}-", "")

          # We need to search by pattern matching since exact match might not work
          # due to potential truncation in the slug generation
          find_by_slug_pattern("#{prefix}-#{encoded_part}%")
        else
          find_by_slug(id)
        end
      end

      # Add a method to find by slug pattern (for LIKE queries)
      def self.find_by_slug_pattern(pattern : String)
        query = "SELECT * FROM #{table_name} WHERE slug LIKE ? LIMIT 1"
        db.query_one?(query, pattern, as: self)
      end

      # Use self.db instead of @@db in your queries
      def self.find_by_slug(slug : String)
        begin
          result = self.db.query_one?(
            "SELECT * FROM posts WHERE slug = ?",
            slug,
            as: self
          )
          # Rest of your method...
        rescue ex : DB::Error
          puts "Database error during find_by_slug: #{ex.message}"
          nil
        end
      end
    end
  end
end
