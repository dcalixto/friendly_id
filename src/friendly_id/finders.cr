module FriendlyId
  module Finders
    macro included
      # Define a class-level method to return the table name
      def self.table_name
        {{@type.stringify.split("::").last.downcase.id + "s"}}
      end

      def self.find_by_friendly_id(slug_or_id : String)
        # First, try to find by slug
        if record = find_by_slug(slug_or_id)
          return record
        end

        # Fallback to ID if slug not found
        if slug_or_id.to_i64?
          find_by_id(slug_or_id.to_i64)
        end
      end

      def self.find_by_slug(slug : String)
        begin
          # First try current slugs
          result = @@db.query_one?(
            "SELECT * FROM #{table_name} WHERE slug = ?", 
            slug, 
            as: self
          )

          # If not found, try historical slugs
          if result.nil?
            if historical_record = FriendlyId::Slug.find_by_slug(slug, @@db)
              result = find(historical_record.sluggable_id)
            end
          end

          result
        rescue ex : DB::Error
          puts "Database error during find_by_slug: #{ex.message}"
          nil
        end
      end

      private def self.find_by_id(id : Int64)
        begin
          query = "SELECT * FROM #{table_name} WHERE id = ?"
          @@db.query_one?(query, id, as: self)
        rescue ex : DB::Error
          puts "Database error during find_by_id: #{ex.message}"
          nil
        end
      end
    end
  end
end
