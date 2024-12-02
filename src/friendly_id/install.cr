require "./cli"
require "file_utils"

module FriendlyId
  class Install
    def self.run
      FileUtils.mkdir_p(FriendlyId.config.migration_dir)

      timestamp = Time.utc.to_s("%Y%m%d%H%M%S")
      filename = "#{FriendlyId.config.migration_dir}/#{timestamp}_create_friendly_id_slugs.cr"

      File.write(filename, migration_content)
    end

    private def self.migration_content
      <<-CRYSTAL
      class CreateFriendlyIdSlugs < DB::Migration
        def change
          create table friendly_id_slugs do
            primary_key id : Int64
            add slug : String, null: false
            add sluggable_id : Int64, null: false
            add sluggable_type : String, null: false
            add created_at : Time, null: false, default: :now

            add_index [:sluggable_type, :sluggable_id]
          end
        end
      end
      CRYSTAL
    end
  end
end
