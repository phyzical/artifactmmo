# frozen_string_literal: true

module BadgesService
  class << self
    def init
      @init ||= pull
    end

    def badge(code:)
      badges(code:)&.first
    end

    def badges(code: nil)
      @badges ||= init.group_by(&:code)
      @badges[code] || init
    end

    private

    def pull
      API::Action.new.badges
    end
  end
end
