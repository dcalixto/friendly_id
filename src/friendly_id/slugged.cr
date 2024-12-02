module FriendlyId
  module Slugged
    macro included
      property slug : String? = nil
      @slug_changed : Bool = false
      @previous_value : String? = nil
      
      macro slug_from(field)
        def generate_slug
          source_value = self.{{field.id}}
          if @previous_value != source_value
            self.slug = normalize_friendly_id(source_value.to_s)
            @slug_changed = true
            @previous_value = source_value
          end
        end
      end

      # Default to title if no field specified
      slug_from title
      
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
