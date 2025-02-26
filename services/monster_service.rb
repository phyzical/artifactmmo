# frozen_string_literal: true

module MonsterService
  class << self
    def items
      @items ||= pull
    end

    def monster(code:)
      monsters(code:).first
    end

    def monsters(code:)
      items.find { |item| item.code == code }
    end

    private

    def pull
      API::Action.new.monsters
    end
  end
end
