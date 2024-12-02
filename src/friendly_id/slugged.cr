module FriendlyId
  module Slugged
    macro included
      property slug : String?

      before_save :set_slug

      def self.slug_base
        @slug_base || "title" # Default to `title` if not set
      end

      def self.set_slug_base(base : String)
        @slug_base = base
      end

      def slug_base_value
        send(self.class.slug_base).to_s
      end

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
      self.slug = normalize_friendly_id(slug_base_value)
    end
  end
end
