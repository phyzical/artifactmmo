# frozen_string_literal: true

module Item
  CODES = { orc: 'orc', ogre: 'ogre', pig: 'pig', cyclops: 'cyclops', chicken: 'chicken', cow: 'cow' }.freeze

  def self.new(keys)
    keys[:effects] = keys[:effects].map { |effect| Effect.new(**effect) }
    keys[:craft] = Craft.new(**keys[:craft]) if keys[:craft]
    Item.new(**keys)
  end

  Item = Struct.new(:name, :code, :level, :type, :subtype, :description, :effects, :craft, :tradeable)
end
