# frozen_string_literal: true

module TasksService
  class << self
    def items
      @items ||= pull
    end

    def task(code:)
      tasks(code:)&.first
    end

    def tasks(code: nil)
      @tasks ||= items.group_by(&:code)
      @tasks[code] || @tasks.values.flatten
    end

    private

    def pull
      API::Action.new.tasks
    end
  end
end
