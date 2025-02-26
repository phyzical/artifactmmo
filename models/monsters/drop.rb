# frozen_string_literal: true

module Monsters
  module Drop
    def self.new(keys)
      Item.new(**keys)
    end

    Item = Struct.new(:code, :rate, :min_quantity, :max_quantity, :quantity)
  end
end
