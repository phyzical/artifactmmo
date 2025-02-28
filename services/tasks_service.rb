# frozen_string_literal: true

module TasksService
  class << self
    def init
      @init ||= pull
    end

    def task(code:)
      tasks(code:)&.first
    end

    def tasks(code: nil)
      @tasks ||= init.group_by(&:code)
      @tasks[code] || init
    end

    private

    def pull
      API::Action.new.tasks
    end
  end
end
