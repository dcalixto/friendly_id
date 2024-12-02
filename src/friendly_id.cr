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

  macro has_many(declaration, foreign_key)
        def {{declaration.var}}
           {{declaration.type}}.where({{foreign_key}}: id)
         end
       end
end
