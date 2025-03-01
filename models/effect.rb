# frozen_string_literal: true

module Effect
  TYPES = { equipment: 'equipment', consumable: 'consumable', combat: 'combat' }.freeze
  SUBTYPES = {
    stat: 'stat',
    other: 'other',
    heal: 'heal',
    buff: 'buff',
    debuff: 'debuff',
    special: 'special',
    gathering: 'gathering',
    teleport: 'teleport',
    gold: 'gold'
  }.freeze

  def self.new(keys)
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :code, :value, :description, :type, :subtype)
end
