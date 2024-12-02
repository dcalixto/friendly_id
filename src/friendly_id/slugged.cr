module FriendlyId
  module Slugged
    macro included
      property slug : String?

      def slug_changed?
        @slug_changed == true
      end

      def self.find_by_friendly_id(id)
        find_by(slug: id)
      end
    end

    def normalize_friendly_id(value : String) : String
      value.downcase
        .gsub(/[^a-z0-9\s-]/, "")
        .gsub(/\s+/, "-")
        .strip("-")
    end

    private def set_slug
      self.slug = normalize_friendly_id(base_value.to_s)
    end
  end
end
