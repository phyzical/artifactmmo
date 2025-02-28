# frozen_string_literal: true

module Reward
  def self.new(keys)
    keys[:items] = keys[:items].map { |item| Characters::Item.new(**item) } if keys[:items]
    Thing.new(**keys)
  end

  Thing = Struct.new(:gold, :items)
end
