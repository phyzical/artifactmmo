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
      @achievements ||= init.group_by(&:code)
      @achievements[code] || init
    end

    private

    def pull
      API::Action.new.achievements
    end
  end
end
