module FriendlyId
  module Slugged
    include FriendlyId::Finders

    macro included
      property slug : String? = nil
      @slug_changed : Bool = false
      @previous_value : String? = nil
      @previous_slug : String? = nil

      @@slug_field : Symbol = :title

      def self.slug_field
        @@slug_field
      end
    end
def generate_slug
  field = self.class.slug_field
  source_value = self[field]?.try(&.to_s) || ""
  if should_generate_new_friendly_id?(source_value)
    @previous_slug = @slug
    self.slug = normalize_friendly_id(source_value)
    @slug_changed = true
    @previous_value = source_value
  end
rescue ex : Exception
  puts "Error generating slug: #{ex.message}"
end
    end    macro friendly_id(field)
      @@slug_field = {{field}}
    end

    def should_generate_new_friendly_id?(new_value)
      @previous_value != new_value || @slug.nil?
    end

    private def normalize_friendly_id(value : String) : String
      value.downcase
        .gsub(/[^a-z0-9\s-]/, "")
        .gsub(/\s+/, "-")
        .strip("-")
    end

    private def store_previous_slug
      @previous_slug = @slug if @slug_changed
      puts "Stored previous slug: #{@previous_slug}" if @previous_slug
    end

    private def update_slug_history(db : DB::Database)
      return unless respond_to?(:slug_history)

      current_slug_was = slug_was
      return unless slug != current_slug_was && current_slug_was

      db.transaction do
        slug_history << current_slug_was.to_s unless slug_history.includes?(current_slug_was)
        create_slug_record(db) if respond_to?(:create_slug_record)
      end
    rescue ex : DB::Error
      handle_db_error(ex, "Failed to update slug history")
    end

    private def create_slug_record(db : DB::Database)
      db.exec "INSERT INTO slugs (slug, sluggable_id, sluggable_type) VALUES (?, ?, ?)",
        slug_was, id.not_nil!, self.class.name
    rescue ex : DB::Error
      handle_db_error(ex, "Error creating slug record")
    end

    private def slug_was
      @previous_slug ||= @slug
    end

    private def handle_db_error(ex : DB::Error, context_message : String)
      puts "#{context_message}: #{ex.message}"
    end
  end
end
