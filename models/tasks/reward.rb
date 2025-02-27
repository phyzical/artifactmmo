# frozen_string_literal: true

module Tasks
  module Reward
    def self.new(keys)
      keys[:items] = keys[:items].map { |item| Characters::Item.new(**item) }
      Thing.new(**keys)
    end

    Thing = Struct.new(:gold, :items)
  end
end
