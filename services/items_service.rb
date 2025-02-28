# frozen_string_literal: true

module ItemsService
  class << self
    def init
      @init ||= pull
    end

    def item(code:)
      items(code:)&.first
    end

    def items(code: nil)
      @items ||= init.group_by(&:code)
      @items[code] || init
    end

    private

    def pull
      API::Action.new.items
    end
  end
end
