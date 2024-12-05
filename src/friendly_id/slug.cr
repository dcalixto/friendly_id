require "db"
require "db/serializable"

module FriendlyId
  class Slug
    include DB::Serializable
    include DB::Mappable

    property id : Int64?
    property slug : String
    property sluggable_id : Int64
    property sluggable_type : String
    property created_at : Time

    def initialize(@slug : String, @sluggable_id : Int64, @sluggable_type : String, @created_at : Time = Time.utc)
    end

    def self.where(conditions)
      query = "SELECT * FROM friendly_id_slugs WHERE sluggable_id = ? AND sluggable_type = ?"
      @@db.query_all(query, conditions[:sluggable_id], conditions[:sluggable_type], as: self)
    end

    def self.create!(slug : String, sluggable_id : Int64, sluggable_type : String)
      @@db.exec(
        "INSERT INTO friendly_id_slugs (slug, sluggable_id, sluggable_type, created_at) VALUES (?, ?, ?, ?)",
        slug, sluggable_id, sluggable_type, Time.utc
      )
    end

    def self.normalize(str : String) : String
      str.downcase
        .tr("àáâãäçèéêëìíîïñòóôõöùúûüýÿ",
          "aaaaaceeeeiiiinooooouuuuyy")
        .gsub(/[^a-z0-9\s-]/, "")
        .strip
        .gsub(/\s+/, "-")
        .gsub(/-+/, "-")
    end

    # Retrieves a slug from a database, filtering by the slug field
    def self.find_by_slug(slug : String, db : DB::Database) : FriendlyId::Slug?
      begin
        db.query_one?("SELECT * FROM friendly_id_slugs WHERE slug = ?", slug, as: Slug)
      rescue ex : DB::Error
        puts "Error querying slug: #{ex.message}"
        nil
      end
    end
  end
end

class String
  def to_slug
    FriendlyId::Slug.normalize(self)
  end
end
