require "../../src/friendly_id/history"
require "spec"
require "../spec_helper"

module FriendlyId
  class TestModel
    include History

    property id : Int64?
    property slug : String?

    def initialize(@id : Int64? = nil)
    end

    def slug=(new_slug : String?)
      puts "DEBUG: Setting slug from #{@slug} to #{new_slug}"
      @slug_changed = true                       # Set change flag
      @previous_slug = @slug.try(&.dup) if @slug # Store previous value
      @slug = new_slug
    end

    def save
      puts "DEBUG: Save called"
      puts "  - id: #{@id}"
      puts "  - slug: #{@slug}"
      puts "  - previous: #{@previous_slug}"
      puts "  - changed: #{@slug_changed}"

      before_save
      puts "  After before_save:"
      puts "    - previous: #{@previous_slug}"

      after_save
      puts "  After after_save:"
      puts "    - history: #{slug_history.inspect}"
      self
    end

    def slug_was
      @previous_slug || @slug
    end

    def update(attributes)
      before_save
      # Update attributes here
      after_save
      self
    end

    # Add this method
    def slugs
      if @id.nil? # Change from id.nil? to @id.nil?
        raise Exception.new("ID is missing for #{self.class.name}")
      end

      FriendlyId::Slug.where({
        sluggable_id:   @id.not_nil!,
        sluggable_type: self.class.name,
      })
    end

    def set_previous_slug(value : String)
      @previous_slug = value
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
    # In the test...
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
    it "tracks historical slugs" do
      model = FriendlyId::TestModel.new(1_i64)
      model.slug = "old-slug"
      model.save

      model.slug = "new-slug"
      model.save

      expect(model.slug_history).to eq(["old-slug"])
    end
  end
end
