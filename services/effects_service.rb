# frozen_string_literal: true

module EffectsService
  class << self
    def init
      @init ||= pull
    end

    def equipment_effects(code: nil, subtype: nil)
      @equipment_effects ||= init.select { |effect| effect.type == Effect::TYPES[:equipment] }
      @equipment_effects.select { |effect| effect.code == code || effect.subtype == subtype } || @equipment_effects
    end

    def equipment_effect(code: nil, subtype: nil)
      equipment_effects(code:, subtype:)&.first
    end

    def consumable_effects(code: nil, subtype: nil)
      @consumable_effects ||= init.select { |effect| effect.type == Effect::TYPES[:consumable] }
      @consumable_effects.select { |effect| effect.code == code || effect.subtype == subtype } || @consumable_effects
    end

    def consumable_effect(code: nil, subtype: nil)
      consumable_effects(code:, subtype:)&.first
    end

    def combat_effects(code: nil, subtype: nil)
      @combat_effects ||= init.select { |effect| effect.type == Effect::TYPES[:combat] }
      @combat_effects.select { |effect| effect.code == code || effect.subtype == subtype } || @combat_effects
    end

    def combat_effect(code: nil, subtype: nil)
      combat_effects(code:, subtype:)&.first
    end

    private

    def pull
      API::Action.new.effects
    end
  end
end
