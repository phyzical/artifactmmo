# frozen_string_literal: true

module Locations
  module Map
    def self.new(keys)
      Thing.new(**keys)
    end

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

    Thing =
      Struct.new(:name, :skin, :x, :y, :type, :code) do
        def initialize(keys)
          content = keys.delete(:content) || {}
          super(**content, **keys)
        end

        def item
          if type == TYPES[:monster]
            MonsterService.monster(code:)
            # elsif type == TYPES[:resource]
            #   Resource.new(code: code)
          elsif type == TYPES[:bank]
            BankService.bank
            # elsif type == TYPES[:npc]
            #   Npc.new(code: code)
            # elsif type == TYPES[:tasks_master]
            #   TasksMaster.new(code: code)
            # elsif type == TYPES[:workshop]
            #   Workshop.new(code: code)
            # elsif type == TYPES[:grand_exchange]
            #   GrandExchange.new(code: code)
          end
        end

        def position
          { x:, y: }
        end
      end
  end
end
