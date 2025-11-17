# frozen_string_literal: true

module Skills
  module Skill
    CODES = ::Skill::Constants::CODES

    def self.new(keys)
      keys[:code] = Skill.code(code: keys.delete(:code))
      Thing.new(**keys)
    end

    def self.code(code:)
      CODES[code.to_sym] || raise(ArgumentError, "Invalid code: #{code}")
    end

    Thing =
      Struct.new(:code, :level_xp, :level, :level_up_xp) do
        def overview
          "Skill: #{code}, Level: #{level}, XP: #{level_xp}, Level up XP: #{level_up_xp}"
        end
      end
  end
end
