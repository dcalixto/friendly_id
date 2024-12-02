module FriendlyId
  module Finders
    macro included
      @@table_name : String = {{@type.stringify.downcase.split("::").last + "s"}}

      def self.find_by_friendly_id(slug : String)
        query = "SELECT * FROM #{@@table_name} WHERE slug = ?"
        @@db.query_one?(query, slug, as: self)
      end
    end
  end
end
