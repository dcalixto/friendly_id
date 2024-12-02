module FriendlyId
  module Slugged
    include FriendlyId::Finders

    macro included
      property slug : String? = nil
      @slug_changed : Bool = false
      @previous_value : String? = nil
      @previous_slug : String? = nil

      before_save :store_previous_slug
      after_save :update_slug_history
    end

    def generate_slug
      source_value = self.title
      if should_generate_new_friendly_id?(source_value)
        @previous_slug = @slug
        self.slug = normalize_friendly_id(source_value.to_s)
        @slug_changed = true
        @previous_value = source_value
      end
    end

    def should_generate_new_friendly_id?(new_value)
      @previous_value != new_value || @slug.nil?
    end

    macro friendly_id(field)
      def generate_slug
        source_value = self.{{field.id}}
        if should_generate_new_friendly_id?(source_value)
          @previous_slug = @slug
          self.slug = normalize_friendly_id(source_value.to_s)
          @slug_changed = true
          @previous_value = source_value
        end
      end
    end

    private def normalize_friendly_id(value : String) : String
      value.downcase
        .gsub(/[^a-z0-9\s-]/, "")
        .gsub(/\s+/, "-")
        .strip("-")
    end

    private def store_previous_slug
      @previous_slug = @slug if @slug_changed
    end
  end
end
