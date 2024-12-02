require "spec"
require "../../src/friendly_id/slug"
require "../spec_helper"

module FriendlyId
  describe Slug do
    describe ".normalize" do
      it "converts string to lowercase" do
        "HELLO WORLD".to_slug.should eq("hello-world")
      end

      it "removes accents" do
        "café".to_slug.should eq("cafe")
      end

      it "handles multiple spaces" do
        "hello   world".to_slug.should eq("hello-world")
      end

      it "removes special characters" do
        "hello@#$%^&*()world".to_slug.should eq("helloworld")
      end

      it "handles empty string" do
        "".to_slug.should eq("")
      end

      it "handles string with only special characters" do
        "@#$%^&*()".to_slug.should eq("")
      end

      it "trims leading and trailing spaces" do
        "  hello world  ".to_slug.should eq("hello-world")
      end

      it "handles multiple dashes" do
        "hello---world".to_slug.should eq("hello-world")
      end
    end
  end
end
