require "../spec_helper"
require "../../src/friendly_id/install"
Spectator.describe FriendlyId::Install do
  before_each do
    # Clear any existing migration files
    Dir.glob("db/migrations/*_create_friendly_id_slugs.sql").each do |file|
      File.delete(file)
    end
  end

  it "creates migration file with correct content" do
    FriendlyId::Install.run
    migration_files = Dir.glob("db/migrations/*_create_friendly_id_slugs.sql")
    expect(migration_files.size).to eq(1)
  end
end
