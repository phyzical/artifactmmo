# frozen_string_literal: true

module Locations
  module Maps
    module Access
      def self.new(keys)
        Thing.new(**keys)
      end

      #  TODO: support multikey
      TYPES = {
        standard: 'standard',
        teleportation: 'teleportation',
        conditional: 'conditional',
        blocked: 'blocked'
      }.freeze

      def self.type(type:)
        TYPES[type.to_sym] || raise(ArgumentError, "Invalid type: #{type}")
      end

      Thing =
        Struct.new(:type, :conditions) do
          def initialize(keys)
            keys[:type] = Access.type(type: keys.delete(:type))
            keys[:conditions] = keys.delete(:conditions).map { ::Condition.new(it) }
            super(**keys)
          end

          def overview
            "Type: #{type}, Conditions: #{conditions.map(&:overview).join('; ')}"
          end
        end
    end
  end
end
