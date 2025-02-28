# frozen_string_literal: true

module Characters
  module Skill
    CODES = {
      alchemy: 'alchemy',
      cooking: 'cooking',
      fishing: 'fishing',
      gearcrafting: 'gearcrafting',
      jewelrycrafting: 'jewelrycrafting',
      mining: 'mining',
      weaponcrafting: 'weaponcrafting',
      woodcutting: 'woodcutting'
    }.freeze

    def self.new(keys)
      Thing.new(**keys)
    end

    def self.code(code:)
      CODES[code.to_sym] || raise(ArgumentError, "Invalid code: #{code}")
    end

    Thing = Struct.new(:level_xp, :level, :level_up_xp)
  end
end
