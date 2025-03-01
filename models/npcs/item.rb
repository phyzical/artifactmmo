# frozen_string_literal: true

module NPCs
  module Item
    def self.new(keys)
      keys.delete(:npc)
      Thing.new(**keys)
    end

    Thing = Struct.new(:code, :buy_price, :sell_price)
  end
end
