module FriendlyId
  module Finders
    macro included
      def self.find_by_friendly_id(id : String)
        # Try to parse as integer first
        id_as_int = id.to_i64? rescue nil

        if id_as_int
          find_by_id(id_as_int)
        elsif id.starts_with?("cjk-")
          # This is a Base64 encoded multilingual slug
          # We need to search by pattern matching since exact match might not work
          # due to potential truncation in the slug generation
          encoded_part = id.sub("cjk-", "")
          find_by_slug_pattern("cjk-#{encoded_part}%")
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
