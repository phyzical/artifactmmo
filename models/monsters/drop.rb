# frozen_string_literal: true

module Monsters
  module Drop
    def self.new(keys)
      Thing.new(**keys)
    end

    Thing = Struct.new(:code, :rate, :min_quantity, :max_quantity, :quantity)
  end
end
