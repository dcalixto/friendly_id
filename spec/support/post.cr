class Post < FriendlyId::BaseModel
  include FriendlyId::Slugged
  include FriendlyId::History

  property id : Int64?
  property title : String
  property body : String
  property user_id : Int64
  property slug : String?

  def initialize(@title : String, @body : String, @user_id : Int64)
  end

  def ==(other : Post)
    id == other.id &&
      title == other.title &&
      body == other.body &&
      user_id == other.user_id &&
      slug == other.slug
  end

  def save
    generate_slug
    TestDB.database.exec "INSERT INTO posts (title, body, user_id, slug) VALUES (?, ?, ?, ?)",
      @title, @body, @user_id, @slug
    @id = TestDB.database.scalar("SELECT last_insert_rowid()").as(Int64)
    self
  end

  def self.create!(title : String, body : String, user_id : Int64) : Post
    post = new(title, body, user_id)
    post.save
    post
  end

  def self.where(user_id : Int64)
    results = [] of Post
    TestDB.database.query("SELECT id, title, body, user_id, slug FROM posts WHERE user_id = ?", user_id) do |rs|
      rs.each do
        id = rs.read(Int64)
        post = new(
          rs.read(String), # title
          rs.read(String), # body
          rs.read(Int64)   # user_id
        )
        post.id = id
        post.slug = rs.read(String?)
        results << post
      end
    end
    results
  end
end
