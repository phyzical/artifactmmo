# frozen_string_literal: true

module ItemsService
  class << self
    def items
      @items ||= pull
    end

    private

    def pull
      API::Action.new.items
    end
  end
end
