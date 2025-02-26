# frozen_string_literal: true

module Locations
  module Bank
    def self.new(keys)
      Item.new(**keys)
    end

    Item = Struct.new(:slots, :expansions, :next_expansion_cost, :gold, :items)
  end
end
