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

    # def initialize(@slug, @sluggable_id, @sluggable_type, @id = nil, @created_at = Time.utc)
    # end
    def initialize(@slug : String, @sluggable_id : Int64, @sluggable_type : String, @id : Int64? = nil, @created_at : Time = Time.utc)
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
        db.query_one?("SELECT * FROM slugs WHERE slug = ?", slug, as: Slug)
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
