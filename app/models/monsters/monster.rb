# frozen_string_literal: true

module Monsters
  module Monster
    CODES = Constants::CODES
    TYPES = Constants::TYPES

    def self.new(keys)
      keys[:code] = Monster.code(code: keys.delete(:code))
      keys[:type] = Monster.type(type: keys.delete(:type))
      keys[:drops] = keys[:drops].map { |drop| Drop.new(**drop) }
      keys[:effects] = keys[:effects].map { |drop| Effect.new(**drop) }
      Thing.new(**keys)
    end

    def self.type(type:)
      TYPES[type.to_sym] || raise(ArgumentError, "Invalid type: #{type}")
    end

    def self.code(code:)
      CODES[code.to_sym] || raise(ArgumentError, "Invalid code: #{code}")
    end

    Thing =
      Struct.new(
        :name,
        :type,
        :code,
        :initiative,
        :level,
        :hp,
        :attack_fire,
        :attack_earth,
        :attack_water,
        :attack_air,
        :res_fire,
        :res_earth,
        :res_water,
        :res_air,
        :critical_strike,
        :effects,
        :min_gold,
        :max_gold,
        :drops
      )
  end
end
