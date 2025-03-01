# frozen_string_literal: true

module Item
  TYPES = {
    utility: 'utility',
    body_armor: 'body_armor',
    weapon: 'weapon',
    resource: 'resource',
    leg_armor: 'leg_armor',
    helmet: 'helmet',
    boots: 'boots',
    shield: 'shield',
    amulet: 'amulet',
    ring: 'ring',
    artifact: 'artifact',
    currency: 'currency',
    consumable: 'consumable',
    rune: 'rune',
    bag: 'bag'
  }.freeze

  CREATION_TYPE = Characters::Skill::CODES

  def self.new(keys)
    keys[:effects] = keys[:effects].map { |effect| Effect.new(**effect) }
    keys[:craft] = Characters::Craft.new(**keys[:craft]) if keys[:craft]
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :code, :level, :type, :subtype, :description, :effects, :craft, :tradeable)
end
