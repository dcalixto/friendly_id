module FriendlyId
  module Slugged
    include FriendlyId::Finders

    # Main include macro remains the same
    macro included
      property slug : String? = nil
      @slug_changed : Bool = false
      @previous_value : String? = nil

      def generate_slug
        source_value = self.title
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

    # New macro to override slug source
    macro friendly_id(field)
      def generate_slug
        source_value = self.{{field.id}}
        if @previous_value != source_value
          self.slug = normalize_friendly_id(source_value.to_s)
          @slug_changed = true
          @previous_value = source_value
        end
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
