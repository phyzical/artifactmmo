# frozen_string_literal: true

module MonsterService
  class << self
    def items
      @items ||= pull
    end

    private

    def pull
      API::Action.new.monsters
    end
  end
end
