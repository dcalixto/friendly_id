require "db"
require "sqlite3"

module FriendlyId
  module UpdateBehavior
    # Updates attributes and tracks changes
    def update!(attributes)
      attributes.each do |key, value|
        case key
        when :title
          self.title = value
        when :slug
          track_slug_change(value)
        else
          raise ArgumentError.new("Invalid attribute: #{key}")
        end
      end
      save!
    end

    private def track_slug_change(new_slug : String)
      if slug != new_slug && !slug.empty?
        slug_history << slug unless slug_history.includes?(slug)
      end
      self.slug = new_slug
    end
  end
end
