# frozen_string_literal: true

module Locations
  module Bank
    def self.new(keys)
      Thing.new(**keys)
    end

    Thing = Struct.new(:slots, :expansions, :next_expansion_cost, :gold, :items)
  end
end
