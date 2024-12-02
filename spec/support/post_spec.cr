require "../spec_helper"
require "../support/post"

require "spectator"

Spectator.describe FriendlyId do
  context "FriendlyId::Slugged" do
    it "generates a slug from a title" do
      post = Post.create("Hello World", "Content", 1)
      post.save
      expect(post.slug).to eq("hello-world")
    end

    it "handles special characters" do
      post = Post.create("Hello & World!", "Content", 1)
      post.save
      expect(post.slug).to eq("hello-world")
    end

    it "handles spaces" do
      post = Post.create("My Great Post", "Content", 1)
      post.save
      expect(post.slug).to eq("my-great-post")
    end
  end

  context "FriendlyId::History" do
    it "keeps track of old slugs" do
      post = Post.create("First Title", "Content", 1)
      post.save
      old_slug = post.slug
      post.update!(title: "New Title")
      expect(post.slug).to eq("new-title")
      expect(post.slug_history.includes?(old_slug)).to be_true
    end
  end
end
