require "../../src/friendly_id/base_model"
require "../../src/friendly_id/history"
require "spec"
require "spectator"
require "../spec_helper"

module FriendlyId
  class TestModel < BaseModel
    include History

    # Add a setter method for testing
    def set_previous_slug(value : String)
      @previous_slug = value
    end

    # Make private methods public for testing
    def update_slug_history
      super
    end

    def create_slug_record
      super
    end

    def slug_was
      super
    end

    def initialize(id : Int64? = nil)
      super(id)
    end
  end

  abstract class BaseModel
    property id : Int64?
    property slug : String?

    def initialize(id : Int64? = nil, slug : String? = nil)
      @id = id
      @slug = slug
    end
  end

  class Slug
    property sluggable_id : Int64
    property sluggable_type : String
    property slug : String
    property created_at : Time

    # Mock in-memory storage for testing
    @@slugs = [] of Slug

    def initialize(slug : String, sluggable_id : Int64, sluggable_type : String)
      @slug = slug
      @sluggable_id = sluggable_id
      @sluggable_type = sluggable_type
      @created_at = Time.utc
    end

    # Simulates an ActiveRecord-style `where` query
    def self.where(criteria : NamedTuple(sluggable_id: Int64, sluggable_type: String))
      @@slugs.select do |slug_record|
        slug_record.sluggable_id == criteria[:sluggable_id] &&
          slug_record.sluggable_type == criteria[:sluggable_type]
      end
    end

    # Simulates record creation
    def self.create!(slug : String, sluggable_id : Int64, sluggable_type : String)
      new_slug = new(slug, sluggable_id, sluggable_type)
      @@slugs << new_slug
      new_slug
    end

    # Simulates record retrieval
    def self.all
      @@slugs
    end
  end
end

Spectator.describe FriendlyId::TestModel do
  # Add a clear method to Slug class
  def FriendlyId::Slug.clear_all
    @@slugs = [] of FriendlyId::Slug
  end

  before_each do
    FriendlyId::Slug.clear_all
  end

  let(model) { FriendlyId::TestModel.new(1_i64).tap { |m| m.slug = "initial-slug" } }

  describe "#slugs" do
    it "retrieves all slug records" do
      model_id = model.id.not_nil!

      FriendlyId::Slug.create!(
        slug: "initial-slug",
        sluggable_id: model_id,
        sluggable_type: model.class.name
      )

      FriendlyId::Slug.create!(
        slug: "new-slug",
        sluggable_id: model_id,
        sluggable_type: model.class.name
      )

      slugs = model.slugs.map(&.slug)
      expect(slugs).to eq ["initial-slug", "new-slug"]
    end

    it "raises error when ID is missing" do
      model_without_id = FriendlyId::TestModel.new
      expect_raises(Exception, "ID is missing for FriendlyId::TestModel") do
        model_without_id.slugs
      end
    end
  end

  describe "#slug_history" do
    it "returns empty array when no history exists" do
      expect(model.slug_history).to eq [] of String
    end

    it "returns array of historical slugs" do
      model_id = model.id.not_nil!

      FriendlyId::Slug.create!(
        slug: "old-slug",
        sluggable_id: model_id,
        sluggable_type: model.class.name
      )

      expect(model.slug_history).to eq ["old-slug"]
    end
  end

  describe "#update_slug_history" do
    it "tracks slug changes" do
      model_id = model.id.not_nil!
      initial_slug = "initial-slug"

      # Create initial slug record
      FriendlyId::Slug.create!(
        slug: initial_slug,
        sluggable_id: model_id,
        sluggable_type: model.class.name
      )

      # Change the slug and update history
      model.slug = "new-slug"
      model.update_slug_history

      expect(model.slug_history).to contain(initial_slug)
    end
  end

  describe "#create_slug_record" do
    it "creates a new slug record for historical slugs" do
      model_id = model.id.not_nil!
      old_slug = "old-slug"
      model.set_previous_slug(old_slug)

      model.create_slug_record

      created_slug = FriendlyId::Slug.where({
        sluggable_id:   model_id,
        sluggable_type: model.class.name,
      }).first

      expect(created_slug.try(&.slug)).to eq old_slug
    end
  end
end
