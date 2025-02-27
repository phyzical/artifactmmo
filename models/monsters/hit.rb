# frozen_string_literal: true

module Monsters
  module Hit
    def self.new(keys)
      Thing.new(**keys)
    end

    Thing = Struct.new(:fire, :earth, :water, :air, :total)
  end
end
