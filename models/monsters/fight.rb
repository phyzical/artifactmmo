# frozen_string_literal: true

module Monsters
  module Fight
    def self.new(keys)
      keys = keys[:fight]
      keys[:drops] = keys[:drops].map { |drop| Drop.new(**drop) }
      keys[:monster_blocked_hits] = Hit.new(**keys[:monster_blocked_hits]) if keys[:monster_blocked_hits]
      keys[:player_blocked_hits] = Hit.new(**keys[:player_blocked_hits]) if keys[:player_blocked_hits]
      keys[:win] = keys.delete(:result) == 'win'

      Thing.new(**keys)
    end

    Thing = Struct.new(:xp, :gold, :drops, :turns, :monster_blocked_hits, :player_blocked_hits, :logs, :win)
  end
end
