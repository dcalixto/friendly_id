module FriendlyId
  module Slugged
    macro included
      class_property slug_base : String = "title"
      property slug : String? = nil
      @slug_changed : Bool = false
      @previous_value : String? = nil
      
      def self.slug_from(field_name : String)
        self.slug_base = field_name
      end

      def generate_slug
        source_value = self.responds_to?(self.class.slug_base) ? self.send(self.class.slug_base) : ""
        if @previous_value != source_value
          self.slug = normalize_friendly_id(source_value.to_s)
          @slug_changed = true
          @previous_value = source_value
        end
      end

      def save
        generate_slug
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
