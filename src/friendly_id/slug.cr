require "db"
require "db/serializable"

module FriendlyId
  class Slug
    include DB::Serializable

    property id : Int64?
    property slug : String
    property sluggable_id : Int64
    property sluggable_type : String
    property created_at : Time

    def initialize(@slug : String, @sluggable_id : Int64, @sluggable_type : String, @created_at : Time = Time.utc)
    end

    # Retrieve slugs based on conditions
    def self.where(conditions) : Array(Slug)
      query = <<-SQL
        SELECT * FROM friendly_id_slugs 
        WHERE sluggable_id = ? AND sluggable_type = ?
      SQL

      @@db.query_all(query, conditions[:sluggable_id], conditions[:sluggable_type], as: self)
    rescue ex : DB::Error
      [] of Slug
    end

    # Create a new slug record
    def self.create!(slug : String, sluggable_id : Int64, sluggable_type : String) : Bool
      query = <<-SQL
        INSERT INTO friendly_id_slugs 
        (slug, sluggable_id, sluggable_type, created_at) 
        VALUES (?, ?, ?, ?)
      SQL

      @@db.exec(query, slug, sluggable_id, sluggable_type, Time.utc)
      true
    rescue ex : DB::Error
      false
    end

    # Generate a normalized slug using the new SlugGenerator
    def self.normalize(str : String, separator : String = "-", preserve_case : Bool = false, locale : String? = nil) : String
      FriendlyId::SlugGenerator.parameterize(str, separator, preserve_case, locale)
    end

    # Find a slug by its value
    def self.find_by_slug(slug : String) : FriendlyId::Slug?
      query = <<-SQL
        SELECT * FROM friendly_id_slugs 
        WHERE slug = ? 
        ORDER BY created_at DESC 
        LIMIT 1
      SQL

      @@db.query_one?(query, slug, as: Slug)
    rescue ex : DB::Error
      nil
    end
  end
end

# Extend String to support slug generation
class String
  def to_slug : String
    FriendlyId::Slug.normalize(self)
  end
end
