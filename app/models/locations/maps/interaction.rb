# frozen_string_literal: true

module Locations
  module Maps
    module Interaction
      TYPES = {
        monster: 'monster',
        resource: 'resource',
        bank: 'bank',
        npc: 'npc',
        tasks_master: 'tasks_master',
        workshop: 'workshop',
        grand_exchange: 'grand_exchange'
      }.freeze

      def self.type(type:)
        TYPES[type.to_sym] || raise(ArgumentError, "Invalid type: #{type}")
      end

      def self.new(keys)
        Thing.new(**keys)
      end

      Thing =
        Struct.new(:content, :transition) do
          def initialize(keys)
            keys[:transition] = Map.new(keys.delete(:transition)) if keys[:transition]&.dig(:content) &&
              keys[:transition][:transition]
            super(**keys)
          end

          def overview
            "Content: #{content}, Transition: #{transition}"
          end
        end
    end
  end
end
