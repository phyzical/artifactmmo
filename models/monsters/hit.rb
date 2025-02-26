# frozen_string_literal: true
module Monsters
  module Hit
    def self.new(keys)
      Item.new(**keys)
    end

    Item = Struct.new(:fire, :earth, :water, :air, :total)
  end
end
