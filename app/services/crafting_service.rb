# frozen_string_literal: true

module CraftingService
  class << self
    def init
      @init ||= pull
    end

    TYPES = Characters::Craft::SKILLS.freeze

    def item(code:)
      items(code:)&.first
    end

    def items(code: nil)
      @items ||= init.group_by(&:code)
      @items[code] || init
    end

    def blending(code: nil)
      @blending ||= items(code:).select { |resource| resource.craft.skill == TYPES[:alchemy] }.group_by(&:code)
      @blending[code] || @blending.values.flatten
    end

    def blend(code:)
      blending(code:)&.first
    end

    def blend_by_level(level:)
      level_check(items: blending, level:)
    end

    def cookings(code: nil)
      @cooking ||= items(code:).select { |resource| resource.craft.skill == TYPES[:cooking] }.group_by(&:code)
      @cooking[code] || @cooking.values.flatten
    end

    def cooking(code:)
      cookings(code:)&.first
    end

    def cooking_by_level(level:)
      level_check(items: cookings, level:)
    end

    def gearcraftings(code: nil)
      @gearcrafting ||= items(code:).select { |resource| resource.craft.skill == TYPES[:gearcrafting] }.group_by(&:code)
      @gearcrafting[code] || @gearcrafting.values.flatten
    end

    def gearcrafting(code:)
      gearcraftings(code:)&.first
    end

    def gearcrafting_by_level(level:)
      level_check(items: gearcraftings, level:)
    end

    def jewelrycraftings(code: nil)
      @jewelrycrafting ||=
        items(code:).select { |resource| resource.craft.skill == TYPES[:jewelrycrafting] }.group_by(&:code)
      @jewelrycrafting[code] || @jewelrycrafting.values.flatten
    end

    def jewelrycrafting(code:)
      jewelrycraftings(code:)&.first
    end

    def jewelrycrafting_by_level(level:)
      level_check(items: jewelrycraftings, level:)
    end

    def weaponcraftings(code: nil)
      @weaponcrafting ||=
        items(code:).select { |resource| resource.craft.skill == TYPES[:weaponcrafting] }.group_by(&:code)
      @weaponcrafting[code] || @weaponcrafting.values.flatten
    end

    def weaponcrafting(code:)
      weaponcraftings(code:)&.first
    end

    def weaponcrafting_by_level(level:)
      level_check(items: weaponcraftings, level:)
    end

    def smelting(code: nil)
      @smelting ||= items(code:).select { |resource| resource.craft.skill == TYPES[:mining] }.group_by(&:code)
      @smelting[code] || @smelting.values.flatten
    end

    def smelt(code:)
      smelting(code:)&.first
    end

    def smelt_by_level(level:)
      level_check(items: smelting, level:)
    end

    private

    def level_check(items:, level:)
      items.sort_by { |resource| -resource.craft.level }.select { |resource| resource.craft.level <= level }&.first
    end

    def pull
      ItemsService.init.select { |item| TYPES.include?(item.craft.skill) }
    end
  end
end
