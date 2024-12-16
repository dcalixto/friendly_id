module FriendlyId
  module History
    macro included
      @previous_slug : String?
      @slug_changed : Bool = false
      property slug_history = [] of String

      def before_save
        puts "DEBUG: before_save"
        puts "  - current slug: #{@slug}"
        puts "  - previous: #{@previous_slug}"
      end

      def after_save
        puts "DEBUG: after_save"
        puts "  - current slug: #{@slug}"
        puts "  - previous: #{@previous_slug}"

        if @slug_changed && @previous_slug && @previous_slug != @slug
          store_slug_history
        end
        @slug_changed = false
      end
    end

    def generate_slug
      source_value = self.responds_to?(:title) ? self.title.to_s : ""

      if should_generate_new_friendly_id?(source_value)
        @previous_slug = @slug
        @slug = FriendlyId::SlugGenerator.parameterize(source_value)
        @slug_changed = true
      end
    end

    private def store_slug_history
      return if @id.nil? || @previous_slug.nil?

      FriendlyId::Slug.create!(
        slug: @previous_slug.not_nil!,
        sluggable_id: @id.not_nil!,
        sluggable_type: self.class.name
      )

      @slug_history << @previous_slug.not_nil!
      puts "DEBUG: Stored in history: #{@previous_slug}"
    end
  end
end
