module FriendlyId
  module Reflection
    macro included
      macro finished
        def respond_to?(method_name)
          {% for method in @type.methods %}
            return true if method_name.to_s == {{method.name.stringify}}
          {% end %}
          false
        end

        def send(method_name)
          case method_name
          {% for method in @type.methods %}
          when {{method.name.symbolize}}
            {{method.name}}
          {% end %}
          else
            raise "Method not found: #{method_name}"
          end
        end
      end
    end
  end
end
