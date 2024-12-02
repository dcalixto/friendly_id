require "db"
require "db/serializable"

module FriendlyId
  abstract class BaseModel
    include DB::Serializable

    # Define ID property as nilable if needed
    property id : Int64?

    # Initialize with an optional id
    def initialize(id : Int64? = nil)
      @id = id
    end

    # Ensure safe access with `not_nil!`
    def id
      @id.not_nil!
    end

    # Define macros as required (unchanged from your implementation)
    macro after_save(method_name)
      def save
        result = super
        {{method_name.id}}
        result
      end
    end

    macro table(name)
      @@table_name = {{name.stringify}}
      def self.table_name
        @@table_name
      end
    end

    macro column(declaration)
      property {{declaration}}
    end

    macro belongs_to(declaration, **options)
      property {{declaration}}
      def related_{{declaration.id}}
        # Add custom logic for relationship resolution if necessary
      end
    end

    # Implement save (still abstract, as before)
    def save
      raise "Save not implemented"
    end
  end
end
