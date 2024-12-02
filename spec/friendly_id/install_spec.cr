require "../spec_helper"
require "../../src/friendly_id/install"

Spectator.describe FriendlyId::Install do
  describe ".run" do
    let(migration_dir) { "spec/db/migrations" }

    before_each do
      FileUtils.rm_rf(migration_dir)
      FileUtils.mkdir_p(migration_dir)
      FriendlyId.configure do |config|
        config.migration_dir = migration_dir
      end
    end

    after_each do
      FileUtils.rm_rf(migration_dir)
    end

    it "creates migration file with correct content" do
      FriendlyId::Install.run

      migration_files = Dir.glob("#{migration_dir}/*_create_friendly_id_slugs.cr")
      expect(migration_files.size).to eq(1)

      content = File.read(migration_files.first)
      expect(content).to contain("class CreateFriendlyIdSlugs < DB::Migration")
      expect(content).to contain("create table friendly_id_slugs")
    end
  end
end
