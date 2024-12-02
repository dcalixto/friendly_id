module FriendlyId
  module History
    macro included
      @previous_slug : String?
      {% if @type < FriendlyId::BaseModel %}
      puts "Including class inherits from FriendlyId::BaseModel"
      after_save :update_slug_history
    {% else %}
      raise "The including class must inherit from FriendlyId::BaseModel to use FriendlyId::History."
    {% end %}
  end

    def slugs
      raise "ID is missing for #{self.class.name}" unless id

      FriendlyId::Slug.where({sluggable_id: id.not_nil!, sluggable_type: self.class.name})
    end

    def slug_history
      raise "ID is missing for #{self.class.name}" unless id

      FriendlyId::Slug.where({sluggable_id: id.not_nil!, sluggable_type: self.class.name})
        .map(&.slug)
    end

    private def create_slug_record
      old_slug = slug_was
      return if old_slug.nil? || slug_history.includes?(old_slug)

      FriendlyId::Slug.create!(
        slug: old_slug,
        sluggable_id: id.not_nil!,
        sluggable_type: self.class.name
      )
    end

    private def update_slug_history
      current_slug_was = slug_was
      return unless slug != current_slug_was && current_slug_was

      slug_history << current_slug_was.to_s unless slug_history.includes?(current_slug_was)
    end

    private def slug_was
      @previous_slug ||= @slug
    end
  end
end
