# frozen_string_literal: true

module MonstersService
  class << self
    def init
      @init ||= pull
    end

    def monster(code:)
      monsters(code:)&.first
    end

    def monsters(code: nil)
      @monsters ||= init.group_by(&:code)
      @monsters[code] || init
    end

    def by_level(level:)
      monsters.sort_by(&:level).reject { |monster| monster.level <= level }&.first
    end

    private

    def pull
      API::Action.new.monsters
    end
  end
end
