require "./spec_helper"
require "spectator"
Spectator.describe FriendlyId do
  describe "slug generation" do
    let(post) do
      created_post = Post.create!(title: "Hello World", body: "Content", user_id: 1_i64)
      created_post.save
      created_post
    end

    it "generates a slug from a title" do
      expect(post.slug.not_nil!).to eq("hello-world")
    end
  end
  # describe "#slug" do
  #   subject(post) { Post.create!(title: "Hello World", body: "Content", user_id: 1_i64) }

  #   it "generates a slug from a title" do
  #     expect(subject.slug).to eq("hello-world")
  #   end
  # end
  # it "generates a slug from a title" do
  #   post = Post.create!(title: "Hello World", body: "Content", user_id: 1_i64)
  #   post.slug.should eq("hello-world")
  # end

  # it "handles special characters" do
  #   post = Post.create!(title: "Hello & World!", body: "Content", user_id: 1)
  #   post.slug.should eq("hello-world")
  # end

  # it "handles spaces" do
  #   post = Post.create!(title: "My Great Post", body: "Content", user_id: 1)
  #   post.slug.should eq("my-great-post")
  # end

  # it "keeps track of old slugs" do
  #   post = Post.create!(title: "First Title", body: "Content", user_id: 1)
  #   old_slug = post.slug
  #   post.update!(title: "New Title")
  #   expect(FriendlyId::History.find_by_friendly_id(old_slug)).to eq(post)
  # end
end
