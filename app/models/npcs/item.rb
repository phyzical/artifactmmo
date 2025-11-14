# frozen_string_literal: true

module Npcs
  module Item
    Codes = NpcItems::Constants::CODES

    def self.new(keys)
      keys.delete(:npc)
      Thing.new(**keys)
    end

    Thing = Struct.new(:code, :buy_price, :sell_price, :currency)
  end
end
