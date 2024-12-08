require "./spec_helper"
require "spectator"
Spectator.describe FriendlyId do
  describe "slug generation" do
    let(post) do
      created_post = Post.new(title: "Hello World", body: "Content", user_id: 1_i64)
      created_post.save
      created_post
    end

    it "generates a slug from a title" do
      expect(post.slug.not_nil!).to eq("hello-world")
    end
  end
end
