# frozen_string_literal: true

require_relative 'skills/skill'

module Item
  TYPES = Items::Constants::TYPES

  CREATION_TYPE = Skills::Skill::CODES

  def self.type(type:)
    TYPES[type.to_sym] || raise(ArgumentError, "Invalid type: #{type}")
  end

  def self.new(keys)
    keys[:type] = Item.type(type: keys.delete(:type)) if keys[:type]
    keys[:effects] = keys[:effects].map { |effect| Effect.new(**effect) }
    keys[:craft] = Characters::Craft.new(**keys[:craft]) if keys[:craft]
    keys[:conditions] = keys[:conditions]&.map { |cond| Condition.new(**cond) } || []
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :code, :level, :type, :subtype, :description, :effects, :craft, :tradeable, :conditions)
end
