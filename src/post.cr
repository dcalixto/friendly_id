class Post
  getter title : String
  getter body : String
  getter user_id : Int64

  @@posts = [] of Post

  def initialize(@title : String, @body : String, @user_id : Int64)
  end

  def self.create(title : String, body : String, user_id : Int64) : Post
    post = new(title, body, user_id)
    @@posts << post
    post
  end

  def self.all
    @@posts
  end

  def friendly_id
    title.downcase
      .gsub(/[^a-z0-9\s-]/, "")
      .gsub(/\s+/, "-")
      .gsub(/^-+|-+$/, "")
  end
end
