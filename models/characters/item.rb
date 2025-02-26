# frozen_string_literal: true

module Characters
  module Item
    CODES = { gold: 'gold' }.freeze

    def self.new(keys)
      Item.new(**keys)
    end

    Item = Struct.new(:slot, :code, :quantity)
  end
end
