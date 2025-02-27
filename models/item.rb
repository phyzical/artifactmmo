# frozen_string_literal: true

module Item
  def self.new(keys)
    keys[:effects] = keys[:effects].map { |effect| Effect.new(**effect) }
    keys[:craft] = Craft.new(**keys[:craft]) if keys[:craft]
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :code, :level, :type, :subtype, :description, :effects, :craft, :tradeable)
end
