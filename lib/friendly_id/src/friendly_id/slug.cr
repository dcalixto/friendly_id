def self.find_by_slug(slug : String, db : DB::Database)
  db.query_one?(
    "SELECT * FROM slugs WHERE slug = ?",
    slug,
    as: self
  )
end
