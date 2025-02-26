# frozen_string_literal: true

module Craft
  SKILLS = {}.freeze

  def self.new(keys)
    keys[:items] = keys[:items].map { |item| Characters::Item.new(**item) }
    Item.new(**keys)
  end
  Item = Struct.new(:skill, :level, :items, :quantity)
end
