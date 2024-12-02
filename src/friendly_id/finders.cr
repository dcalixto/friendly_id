module FriendlyId
  module Finders
    macro included
      @@table_name : String = {{@type.stringify.downcase.split("::").last + "s"}}

      def self.find_by_friendly_id(slug_or_id : String)
        # First try to find by slug
        if record = find_by_slug(slug_or_id)
          return record
        end

        # Fallback to ID if slug not found
        if slug_or_id.to_i64?
          find_by_id(slug_or_id.to_i64)
        end
      end
      
     # private def self.find_by_slug(slug : String)
     #   query = "SELECT * FROM #{@@table_name} WHERE slug = ?"
     #  @@db.query_one?(query, slug, as: self)
     # end


      def self.find_by_slug(slug : String)
        # First try current slugs
        result = @@db.query_one?(
          "SELECT * FROM #{table_name} WHERE slug = ?", 
          slug, 
          as: self
        )
        
        # If not found, try historical slugs
        if result.nil?
          if historical_record = FriendlyId::Slug.find_by_slug(slug)
            result = find(historical_record.sluggable_id)
          end
        end
        
        result
      end
      private def self.find_by_id(id : Int64)
        query = "SELECT * FROM #{@@table_name} WHERE id = ?"
        @@db.query_one?(query, id, as: self)
      end
    end
  end
end