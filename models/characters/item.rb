# frozen_string_literal: true

module Characters
  module Item
    CODES = { gold: 'gold' }.freeze

    def self.new(keys)
      Thing.new(**keys)
    end

    def self.code(code:)
      CODES[code.to_sym] || raise(ArgumentError, "Invalid code: #{code}")
    end

    Thing = Struct.new(:slot, :code, :quantity)
  end
end
