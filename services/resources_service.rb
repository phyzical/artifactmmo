# frozen_string_literal: true

module ResourcesService
  class << self
    def init
      @init ||= pull
    end

    def resource(code:)
      resources(code:)&.first
    end

    def resources(code: nil)
      @resources ||= init.group_by(&:code)
      @resources[code] || init
    end

    def minings(code: nil)
      @mining ||= resources(code:).select { |resource| resource.skill == TYPES[:mining] }.group_by(&:code)
      @mining[code] || @mining.values.flatten
    end

    def mining(code:)
      minings(code:)&.first
    end

    def mining_by_level(level:)
      minings.sort_by(&:level).reject { |resource| resource.level <= level }&.first
    end

    def woodcuttings(code: nil)
      @woodcutting ||= resources(code:).select { |resource| resource.skill == TYPES[:woodcutting] }.group_by(&:code)
      @woodcutting[code] || @woodcutting.values.flatten
    end

    def woodcutting(code:)
      woodcuttings(code:)&.first
    end

    def woodcutting_by_level(level:)
      woodcuttings.sort_by(&:level).reject { |resource| resource.level <= level }&.first
    end

    def fishings(code: nil)
      @fishing ||= resources(code:).select { |resource| resource.skill == TYPES[:fishing] }.group_by(&:code)
      @fishing[code] || @fishing.values.flatten
    end

    def fishing(code:)
      fishings(code:)&.first
    end

    def fishing_by_level(level:)
      fishings.sort_by(&:level).reject { |resource| resource.level <= level }&.first
    end

    def alchemys(code: nil)
      @alchemy ||= resources(code:).select { |resource| resource.skill == TYPES[:alchemy] }.group_by(&:code)
      @alchemy[code] || @alchemy.values.flatten
    end

    def alchemy(code:)
      alchemys(code:)&.first
    end

    def alchemy_by_level(level:)
      alchemys.sort_by(&:level).reject { |resource| resource.level <= level }&.first
    end

    private

    def pull
      API::Action.new.resources
    end
  end
end
