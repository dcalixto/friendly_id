require "db"
require "sqlite3"
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

    def initialize(@slug, @sluggable_id, @sluggable_type, @id = nil, @created_at = Time.utc)
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
  end
end

class String
  def to_slug
    FriendlyId::Slug.normalize(self)
  end
end
