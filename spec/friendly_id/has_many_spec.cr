require "../spec_helper"
require "../support/user"

Spectator.describe FriendlyId do
  describe ".has_many" do
    it "creates a query method for associated records" do
      user = User.create!(name: "Test User")
      post1 = Post.create!(title: "Post 1", body: "Content", user_id: user.id.not_nil!)
      post2 = Post.create!(title: "Post 2", body: "Content", user_id: user.id.not_nil!)
      other_post = Post.create!(title: "Other Post", body: "Content", user_id: 999_i64)

      posts = user.posts
      expect(posts.size).to eq(2)
      expect(posts).to contain(post1)
      expect(posts).to contain(post2)
      expect(posts).not_to contain(other_post)
    end
  end
end
