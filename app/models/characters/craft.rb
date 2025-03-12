# frozen_string_literal: true

module Characters
  module Craft
    SKILLS = {}.freeze

    def self.new(keys)
      keys[:items] = keys[:items].map { |item| Characters::Item.new(**item) }
      Thing.new(**keys)
    end
    Thing = Struct.new(:skill, :level, :items, :quantity)
  end
end
