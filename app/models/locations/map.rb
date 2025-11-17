# frozen_string_literal: true

module Locations
  module Map
    def self.new(keys)
      Thing.new(**keys)
    end

    LAYERS = Maps::Constants::LAYERS

    def self.layer(layer:)
      LAYERS[layer.to_sym] || raise(ArgumentError, "Invalid layer: #{layer}")
    end

    Thing =
      Struct.new(:map_id, :name, :skin, :x, :y, :layer, :access, :interactions, :conditions) do
        def initialize(keys)
          content = keys.delete(:content) || {}
          keys[:layer] = Map.layer(layer: keys.delete(:layer)) if keys.key?(:layer)
          keys[:access] = Maps::Access.new(keys.delete(:access)) if keys.key?(:access)
          keys[:interactions] = Maps::Interaction.new(keys.delete(:interactions)) if keys.key?(:interactions)
          super(**content, **keys)
        end

        def item # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          if type == TYPES[:monster]
            MonstersService.monster(code:)
          elsif type == TYPES[:resource]
            Characters::Resource.new(code:)
          elsif type == TYPES[:bank]
            BankService.bank
          elsif type == TYPES[:npc]
            Npc.new(code:)
          elsif type == TYPES[:tasks_master]
            TasksMaster.new(code:)
          elsif type == TYPES[:workshop]
            Workshop.new(code:)
          elsif type == TYPES[:grand_exchange]
            GrandExchange.new(code:)
          end
        end

        def code
          interactions&.content&.[](:code)
        end

        def type
          interactions&.content&.[](:type)
        end

        def position
          { x:, y: }
        end

        def overview
          "Name: #{name}, Type: #{type}, Code: #{code}, Skin: #{skin}, Position: #{position}"
        end
      end
  end
end
