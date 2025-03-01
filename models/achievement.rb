# frozen_string_literal: true

module Achievement
  TYPES = {
    combat_kill: 'combat_kill',
    combat_drop: 'combat_drop',
    combat_level: 'combat_level',
    gathering: 'gathering',
    crafting: 'crafting',
    recycling: 'recycling',
    task: 'task',
    other: 'other',
    use: 'use'
  }.freeze

  def self.new(keys)
    keys[:reward] = Reward.new(gold: keys.delete(:rewards)[:gold])
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :type, :code, :description, :points, :target, :total, :reward)
end
