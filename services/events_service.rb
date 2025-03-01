# frozen_string_literal: true

module EventsService
  class << self
    def init
      @init ||= pull
    end

    def event(code:)
      events(code:)&.first
    end

    def events(code: nil)
      @events ||= init.group_by(&:code)
      @events[code] || init
    end

    private

    def pull
      API::Action.new.events
    end
  end
end
