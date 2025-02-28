# frozen_string_literal: true

module Monsters
  module Fight
    def self.new(keys)
      keys[:drops] = keys[:drops].map { |drop| Drop.new(**drop) }
      keys[:monster_blocked_hits] = Hit.new(**keys[:monster_blocked_hits]) if keys[:monster_blocked_hits]
      keys[:player_blocked_hits] = Hit.new(**keys[:player_blocked_hits]) if keys[:player_blocked_hits]
      keys[:win] = keys.delete(:result) == 'win'

      Thing.new(**keys)
    end

    Thing =
      Struct.new(:xp, :gold, :drops, :turns, :monster_blocked_hits, :player_blocked_hits, :logs, :win) do
        def overview
          [
            '============== Fight Overview =================',
            "#{win ? 'Win' : 'Lose'}: #{xp} XP, #{gold} gold",
            "Monster: #{monster_blocked_hits.overview}",
            "Player: #{player_blocked_hits.overview}",
            'Last 10 turns:',
            *logs.last(10),
            '==============================================='
          ].join("\n")
        end
      end
  end
end
