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

    def monsters(code: nil)
      @monsters ||= tasks.select { |task| task.type == Task::TYPES[:monster] }.group_by(&:code)
      @monsters[code] || @monsters.values.flatten
    end

    def monster(code:)
      monsters(code:)&.first
    end

    def items(code: nil)
      @items ||= tasks.select { |task| task.type == Task::TYPES[:item] }.group_by(&:code)
      @items[code] || @items.values.flatten
    end

    def item(code:)
      items(code:)&.first
    end

    def weaponcraftings(code: nil)
      @weaponcraftings ||= tasks.select { |task| task.type == Task::CODES[:weaponcrafting] }.group_by(&:code)
      @weaponcraftings[code] || @weaponcraftings.values.flatten
    end

    def weaponcrafting(code:)
      weaponcraftings(code:)&.first
    end

    def gearcraftings(code: nil)
      @gearcraftings ||= tasks.select { |task| task.type == Task::CODES[:gearcrafting] }.group_by(&:code)
      @gearcraftings[code] || @gearcraftings.values.flatten
    end

    def gearcrafting(code:)
      gearcraftings(code:)&.first
    end

    def jewelrycraftings(code: nil)
      @jewelrycraftings ||= tasks.select { |task| task.type == Task::CODES[:jewelrycrafting] }.group_by(&:code)
      @jewelrycraftings[code] || @jewelrycraftings.values.flatten
    end

    def jewelrycrafting(code:)
      jewelrycraftings(code:)&.first
    end

    def cookings(code: nil)
      @cookings ||= tasks.select { |task| task.type == Task::CODES[:cooking] }.group_by(&:code)
      @cookings[code] || @cookings.values.flatten
    end

    def cooking(code:)
      cookings(code:)&.first
    end

    def woodcuttings(code: nil)
      @woodcuttings ||= tasks.select { |task| task.type == Task::CODES[:woodcutting] }.group_by(&:code)
      @woodcuttings[code] || @woodcuttings.values.flatten
    end

    def woodcutting(code:)
      woodcuttings(code:)&.first
    end

    def minings(code: nil)
      @minings ||= tasks.select { |task| task.type == Task::CODES[:mining] }.group_by(&:code)
      @minings[code] || @minings.values.flatten
    end

    def mining(code:)
      minings(code:)&.first
    end

    def alchemys(code: nil)
      @alchemys ||= tasks.select { |task| task.type == Task::CODES[:alchemy] }.group_by(&:code)
      @alchemys[code] || @alchemys.values.flatten
    end

    def alchemy(code:)
      alchemys(code:)&.first
    end

    def fishings(code: nil)
      @fishings ||= tasks.select { |task| task.type == Task::CODES[:fishing] }.group_by(&:code)
      @fishings[code] || @fishings.values.flatten
    end

    def fishing(code:)
      fishings(code:)&.first
    end

    private

    def pull
      API::Action.new.tasks
    end
  end
end
