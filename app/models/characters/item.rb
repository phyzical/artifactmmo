# frozen_string_literal: true

module Characters
  module Item
    CODES = { gold: 'gold' }.freeze

    SLOTS = {
      amulet: 'amulet',
      artifact1: 'artifact1',
      artifact2: 'artifact2',
      artifact3: 'artifact3',
      bag: 'bag',
      body_armor: 'body_armor',
      boots: 'boots',
      helmet: 'helmet',
      leg_armor: 'leg_armor',
      ring1: 'ring1',
      ring2: 'ring2',
      rune: 'rune',
      shield: 'shield',
      weapon: 'weapon',
      utility1: 'utility1',
      utility2: 'utility2'
    }.freeze

    def self.new(keys)
      Thing.new(**keys)
    end

    def self.code(code:)
      CODES[code.to_sym] || raise(ArgumentError, "Invalid code: #{code}")
    end

    Thing = Struct.new(:slot, :code, :quantity)
  end
end
