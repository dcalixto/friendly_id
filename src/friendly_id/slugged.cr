module FriendlyId
  module Slugged
    macro included
      property slug : String? = nil
      @slug_changed : Bool = false
      @previous_value : String? = nil
      
      # Default slug generation from title
      def generate_slug
        source_value = self.title
        if @previous_value != source_value
          self.slug = normalize_friendly_id(source_value.to_s)
          @slug_changed = true
          @previous_value = source_value
        end
      end

      # Macro for custom field selection
      macro slug_from(field_name)
        def generate_slug
          source_value = self.{{field_name.id}}
          if @previous_value != source_value
            self.slug = normalize_friendly_id(source_value.to_s)
            @slug_changed = true
            @previous_value = source_value
          end
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
