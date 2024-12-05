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
