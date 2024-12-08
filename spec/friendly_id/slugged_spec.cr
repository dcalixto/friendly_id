require "../spec_helper"

class TestSluggedModel
  include FriendlyId::Slugged

  @slug_changed : Bool = false

  def title
    base_value
  end

  def base_value
    "Test Value"
  end

  def set_slug
    generate_slug
  end
end

describe FriendlyId::Slugged do
  describe "#normalize_friendly_id" do
    it "converts string to lowercase" do
      model = TestSluggedModel.new
      model.normalize_friendly_id("HELLO WORLD").should eq("hello-world")
    end

    it "replaces spaces with hyphens" do
      model = TestSluggedModel.new
      model.normalize_friendly_id("hello world").should eq("hello-world")
    end

    it "removes special characters" do
      model = TestSluggedModel.new
      model.normalize_friendly_id("hello@#$%^&*world!").should eq("helloworld")
    end

    it "handles multiple spaces" do
      model = TestSluggedModel.new
      model.normalize_friendly_id("hello    world").should eq("hello-world")
    end

    it "strips leading and trailing hyphens" do
      model = TestSluggedModel.new
      model.normalize_friendly_id("-hello world-").should eq("hello-world")
    end

    it "handles empty string" do
      model = TestSluggedModel.new
      model.normalize_friendly_id("").should eq("")
    end
  end

  describe "#generate_slug" do
    it "generates slug from title" do
      model = TestSluggedModel.new
      model.generate_slug
      model.slug.should eq("test-value")
    end
  end

  describe "#slug_changed?" do
    it "returns false by default" do
      model = TestSluggedModel.new
      model.slug_changed?.should be_false
    end
  end
end
