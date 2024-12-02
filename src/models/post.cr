class Post
  # Class variable to store all posts
  @@posts = [] of Post

  # Read-only attributes
  getter title : String
  getter body : String
  getter user_id : Int64

  def self.create(title : String, body : String, user_id : Int64) : Post
    post = new(title, body, user_id)
    @@posts << post
    post
  end

  def self.all
    @@posts
  end

  protected def initialize(@title : String, @body : String, @user_id : Int64)
  end

  def friendly_id : String
    title
      .downcase
      .gsub(/[^a-z0-9\s-]/, "") # Remove special characters
      .gsub(/\s+/, "-")         # Replace spaces with hyphens
      .gsub(/-+/, "-")          # Collapse multiple hyphens
      .gsub(/^-|-$/, "")        # Remove leading/trailing hyphens
  end
end
