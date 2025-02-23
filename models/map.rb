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
    end
end
