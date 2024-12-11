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

    def self.where(conditions) : Array(Slug)
      query = <<-SQL
        SELECT * FROM friendly_id_slugs 
        WHERE sluggable_id = ? AND sluggable_type = ?
      SQL

      @@db.query_all(query, conditions[:sluggable_id], conditions[:sluggable_type], as: self)
    rescue ex : DB::Error
      [] of Slug
    end

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

    def self.normalize(str : String, separator : String = "-", preserve_case : Bool = false, locale : String? = nil) : String
      result = str.clone

      # Transliterate special characters
      result = result.tr("àáâãäçèéêëìíîïñòóôõöùúûüýÿ", "aaaaaceeeeiiiinooooouuuuyy")

      # Strip quotes and non-alphanumeric chars except dashes and underscores
      result = result.gsub(/["']/, "")
        .gsub(/[^a-zA-Z0-9\s\-_]/, "")
        .strip

      # Handle case preservation
      result = result.downcase unless preserve_case

      # Replace whitespace with separator
      result = result.gsub(/\s+/, separator)

      # Collapse multiple separators
      result = result.gsub(/#{separator}{2,}/, separator)

      # Remove leading/trailing separators
      result = result.gsub(/^#{separator}|#{separator}$/, "")

      result
    end

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

class String
  def to_slug : String
    FriendlyId::Slug.normalize(self)
  end
end
