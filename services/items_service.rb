# frozen_string_literal: true

module ItemsService
  class << self
    def init
      @init ||= pull
    end

    def item(code:)
      items(code:)&.first
    end

    def items(code: nil)
      @items ||= init.group_by(&:code)
      @items[code] || init
    end

    def utilities(code: nil)
      @utilities ||= init.select { |item| item.type == TYPES[:utility] }.group_by(&:code)
      @utilities[code] || @utilities.values.flatten
    end

    def utility(code:)
      utilities(code:)&.first
    end

    def body_armors(code: nil)
      @body_armors ||= init.select { |item| item.type == TYPES[:body_armor] }.group_by(&:code)
      @body_armors[code] || @body_armors.values.flatten
    end

    def body_armor(code:)
      body_armors(code:)&.first
    end

    def weapons(code: nil)
      @weapons ||= init.select { |item| item.type == TYPES[:weapon] }.group_by(&:code)
      @weapons[code] || @weapons.values.flatten
    end

    def weapon(code:)
      weapons(code:)&.first
    end

    def resources(code: nil)
      @resources ||= init.select { |item| item.type == TYPES[:resource] }.group_by(&:code)
      @resources[code] || @resources.values.flatten
    end

    def resource(code:)
      resources(code:)&.first
    end

    def leg_armors(code: nil)
      @leg_armors ||= init.select { |item| item.type == TYPES[:leg_armor] }.group_by(&:code)
      @leg_armors[code] || @leg_armors.values.flatten
    end

    def leg_armor(code:)
      leg_armors(code:)&.first
    end

    def helmets(code: nil)
      @helmets ||= init.select { |item| item.type == TYPES[:helmet] }.group_by(&:code)
      @helmets[code] || @helmets.values.flatten
    end

    def helmet(code:)
      helmets(code:)&.first
    end

    def boots(code: nil)
      @boots ||= init.select { |item| item.type == TYPES[:boots] }.group_by(&:code)
      @boots[code] || @boots.values.flatten
    end

    def boot(code:)
      boots(code:)&.first
    end

    def shields(code: nil)
      @shields ||= init.select { |item| item.type == TYPES[:shield] }.group_by(&:code)
      @shields[code] || @shields.values.flatten
    end

    def shield(code:)
      shields(code:)&.first
    end

    def amulets(code: nil)
      @amulets ||= init.select { |item| item.type == TYPES[:amulet] }.group_by(&:code)
      @amulets[code] || @amulets.values.flatten
    end

    def amulet(code:)
      amulets(code:)&.first
    end

    def rings(code: nil)
      @rings ||= init.select { |item| item.type == TYPES[:ring] }.group_by(&:code)
      @rings[code] || @rings.values.flatten
    end

    def ring(code:)
      rings(code:)&.first
    end

    def artifacts(code: nil)
      @artifacts ||= init.select { |item| item.type == TYPES[:artifact] }.group_by(&:code)
      @artifacts[code] || @artifacts.values.flatten
    end

    def artifact(code:)
      artifacts(code:)&.first
    end

    def currencies(code: nil)
      @currencies ||= init.select { |item| item.type == TYPES[:currency] }.group_by(&:code)
      @currencies[code] || @currencies.values.flatten
    end

    def currency(code:)
      currencies(code:)&.first
    end

    def consumables(code: nil)
      @consumables ||= init.select { |item| item.type == TYPES[:consumable] }.group_by(&:code)
      @consumables[code] || @consumables.values.flatten
    end

    def consumable(code:)
      consumables(code:)&.first
    end

    def runes(code: nil)
      @runes ||= init.select { |item| item.type == TYPES[:rune] }.group_by(&:code)
      @runes[code] || @runes.values.flatten
    end

    def rune(code:)
      runes(code:)&.first
    end

    def bags(code: nil)
      @bags ||= init.select { |item| item.type == TYPES[:bag] }.group_by(&:code)
      @bags[code] || @bags.values.flatten
    end

    def bag(code:)
      bags(code:)&.first
    end

    private

    def pull
      API::Action.new.items
    end
  end
end
