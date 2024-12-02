module FriendlyId
  module Slugged
    macro included
      property slug : String?
      @slug_changed : Bool = false
      @slug_base : String = "title"

      def generate_slug
        self.slug = normalize_friendly_id(title)
        @slug_changed = true
      end

      def slug_changed?
        @slug_changed
      end

      def self.find_by_slug(slug : String)
        find_by(slug: slug)
      end

      # Hook into save to generate slug
      def save
        generate_slug if slug.nil? || title_changed?
        super
      end
    end

    def normalize_friendly_id(value : String) : String
      value.downcase
        .gsub(/[^a-z0-9\s-]/, "")
        .gsub(/\s+/, "-")
        .strip("-")
    end
  end
end
