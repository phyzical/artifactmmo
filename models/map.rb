# frozen_string_literal: true

module Map
  def self.new(keys)
    Item.new(**keys)
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

  Item =
    Struct.new(:name, :skin, :x, :y, :type, :code) do
      def initialize(keys)
        content = keys.delete(:content) || {}
        super(**content, **keys)
      end

      def item
        if type == TYPES[:monster]
          Monster.new(code: code)
          # elsif type == TYPES[:resource]
          #   Resource.new(code: code)
          # elsif type == TYPES[:bank]
          #   Bank.new(code: code)
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
