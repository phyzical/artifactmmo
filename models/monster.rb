# frozen_string_literal: true

module Monster
  CODES = { orc: 'orc', ogre: 'ogre', pig: 'pig', cyclops: 'cyclops', chicken: 'chicken', cow: 'cow' }.freeze

  def self.new(keys)
    keys[:drops] = keys[:drops].map { |drop| Drop.new(**drop) }
    keys[:effects] = keys[:effects].map { |drop| Effect.new(**drop) }
    Item.new(**keys)
  end

  Item =
    Struct.new(
      :name,
      :code,
      :level,
      :hp,
      :attack_fire,
      :attack_earth,
      :attack_water,
      :attack_air,
      :res_fire,
      :res_earth,
      :res_water,
      :res_air,
      :critical_strike,
      :effects,
      :min_gold,
      :max_gold,
      :drops
    )
end
