# frozen_string_literal: true

module Badges
  module Condition
    def self.new(keys)
      Thing.new(**keys)
    end
    Thing = Struct.new(:code, :quantity)
  end
end
