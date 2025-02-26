# frozen_string_literal: true

module Tasks
  module Reward
    def self.new(keys)
      keys[:items] = keys[:items].map { |item| Characters::Item.new(**item) }
      Item.new(**keys)
    end

    Item = Struct.new(:gold, :items)
  end
end
