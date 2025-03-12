# frozen_string_literal: true

module AchievementsService
  class << self
    def init
      @init ||= pull
    end

    def achievement(code:)
      achievements(code:)&.first
    end

    def achievements(code: nil)
      @achievements_by_code ||= init.group_by(&:code)
      @achievements_by_code[code] || init
    end

    private

    def pull
      API::Action.new.achievements
    end
  end
end
