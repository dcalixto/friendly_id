module FriendlyId
  module History
    macro included
      @previous_slug : String?
      property slug_history = [] of String

      # Add these hooks directly in the module
      def before_update
        @previous_slug = slug if id
      end

      def before_save
        update_slug_history
      end

      def after_save
        create_slug_record
      end
    end

    def slugs
      return [] of String if id.nil?
      FriendlyId::Slug.where({sluggable_id: id.not_nil!, sluggable_type: self.class.name})
    end

    def slug_history
      return [] of String if id.nil?
      slugs.map(&.slug)
    end

    private def create_slug_record
      return if id.nil?
      old_slug = slug_was
      return if old_slug.nil? || slug_history.includes?(old_slug)

      FriendlyId::Slug.create!(
        slug: old_slug,
        sluggable_id: id.not_nil!,
        sluggable_type: self.class.name
      )
      @slug_history << old_slug
    end

    private def update_slug_history
      return if id.nil?
      current_slug_was = slug_was
      return unless slug != current_slug_was && current_slug_was

      @slug_history << current_slug_was.to_s unless @slug_history.includes?(current_slug_was)
      create_slug_record
    end

    private def slug_was
      @previous_slug ||= @slug
    end
  end
end
