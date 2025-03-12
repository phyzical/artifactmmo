# frozen_string_literal: true

module Monsters
  module Hit
    def self.new(keys)
      Thing.new(**keys)
    end

    Thing =
      Struct.new(:fire, :earth, :water, :air, :total) do
        def overview
          "Fire: #{fire}, Earth: #{earth}, Water: #{water}, Air: #{air}, Total: #{total}"
        end
      end
  end
end
