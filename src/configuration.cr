module FriendlyId
  class Configuration
    property migration_dir : String = "db/migrations"
  end

  @@configuration = Configuration.new

  def self.configure
    yield @@configuration
  end

  def self.config
    @@configuration
  end
end
