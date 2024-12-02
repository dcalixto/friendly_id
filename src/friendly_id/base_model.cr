require "db"
require "db/serializable"

module FriendlyId
  module Model
    module Callbacks
      # Define callback storage
      @@before_save_callbacks = [] of Symbol
      @@after_save_callbacks = [] of Symbol

      # Add before_save macro
      macro before_save(method_name)
        {% if !@type.class_vars.includes?("@@before_save_callbacks".id) %}
          @@before_save_callbacks = [] of Symbol
        {% end %}
        @@before_save_callbacks << {{method_name}}
      end

      # Enhanced after_save macro
      macro after_save(method_name)
        {% if !@type.class_vars.includes?("@@after_save_callbacks".id) %}
          @@after_save_callbacks = [] of Symbol
        {% end %}
        @@after_save_callbacks << {{method_name}}
      end

      # Run callbacks method
      def run_callbacks
        @@before_save_callbacks.each { |callback| self.send(callback) }
        yield
        @@after_save_callbacks.each { |callback| self.send(callback) }
      end
    end

    macro included
      include FriendlyId::Model::Callbacks
      
      def save
        run_callbacks do
          perform_save
        end
      end
    end
  end
end  abstract class BaseModel
    include DB::Serializable
    include Model

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

    # Abstract method for actual save implementation
    protected def perform_save
      raise "Save not implemented"
    end
  end
end
