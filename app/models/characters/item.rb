# frozen_string_literal: true

module Characters
  module Item
    TYPES = {
      weapon: 'weapon',
      boots: 'boots',
      helmet: 'helmet',
      currency: 'currency',
      shield: 'shield',
      leg_armor: 'leg_armor',
      body_armor: 'body_armor',
      amulet: 'amulet',
      bag: 'bag',
      artifact: 'artifact',
      rune: 'rune',
      ring1: 'ring1',
      ring2: 'ring2',
      artifact1: 'artifact1',
      artifact2: 'artifact2',
      artifact3: 'artifact3',
      utility1: 'utility1',
      utility1_slot_quantity: 'utility1_slot_quantity',
      utility2: 'utility2',
      utility2_slot_quantity: 'utility2_slot_quantity'
    }.freeze

    def self.new(keys)
      keys[:conditions] = keys.delete(:conditions)&.map { Condition.new(it) } || []
      keys[:effects] = keys.delete(:effects)&.map { Effect.new(it) } || []
      Thing.new(**keys)
    end

    Thing = Struct.new(:slot, :code, :quantity, :effects, :conditions)
  end
end
