# frozen_string_literal: true

module Badges
  module Badge
    def self.new(keys)
      keys[:conditions] = keys[:conditions].map { |condition| Condition.new(**condition) }
      Thing.new(**keys)
    end
    Thing = Struct.new(:code, :season, :description, :conditions)
  end
end
