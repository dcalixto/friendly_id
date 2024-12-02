module FriendlyId
  module Finders
    macro included
      def self.find_by_friendly_id(slug_or_id : String)
        if record = find_by_slug(slug_or_id)
          return record
        end

        if slug_or_id.to_i64?
          find(slug_or_id.to_i64)
        end
      end

      def self.find_by_slug(slug : String)
        begin
          result = @@db.query_one?(
            "SELECT * FROM posts WHERE slug = ?",
            slug,
            as: self
          )

          if result.nil?
            if historical_record = FriendlyId::Slug.find_by_slug(slug)
              result = find(historical_record.sluggable_id)
            end
          end

          result
        rescue ex : DB::Error
          puts "Database error during find_by_slug: #{ex.message}"
          nil
        end
      end
    end
  end
end
