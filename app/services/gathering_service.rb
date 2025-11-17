# frozen_string_literal: true

module GatheringService
  class << self
    def init
      @init ||= pull
    end

    SKILLS = Characters::Resource::SKILLS.freeze

    def resource(code:)
      resources(code:)&.first
    end

    def resources(code: nil)
      @resources ||= init.group_by(&:code)
      @resources[code] || init
    end

    def minings(code: nil)
      @minings ||= group_by_code(skill: :mining)
      @minings[code] || @minings.values.flatten
    end

    def mining(code:)
      minings(code:)&.first
    end

    def mining_by_level(level:)
      level_check(items: minings, level:)
    end

    def woodcuttings(code: nil)
      @woodcuttings ||= group_by_code(skill: :woodcutting)
      @woodcuttings[code] || @woodcuttings.values.flatten
    end

    def woodcutting(code:)
      woodcuttings(code:)&.first
    end

    def woodcutting_by_level(level:)
      level_check(items: woodcuttings, level:)
    end

    def fishings(code: nil)
      @fishings ||= group_by_code(skill: :fishing)
      @fishings[code] || @fishings.values.flatten
    end

    def fishing(code:)
      fishings(code:)&.first
    end

    def fishing_by_level(level:)
      level_check(items: fishings, level:)
    end

    def alchemys(code: nil)
      @alchemys ||= group_by_code(skill: :alchemy)
      @alchemys[code] || @alchemys.values.flatten
    end

    def alchemy(code:)
      alchemys(code:)&.first
    end

    def alchemy_by_level(level:)
      level_check(items: alchemys, level:)
    end

    private

    def level_check(items:, level:)
      items.sort_by { |resource| -resource.craft.level }.select { |resource| resource.craft.level <= level }&.first
    end

    def group_by_code(skill:)
      resources.select { |resource| resource.skill == SKILLS[skill.to_sym] }.group_by(&:code)
    end

    def pull
      API::Action.new.resources
    end
  end
end
