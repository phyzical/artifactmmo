# frozen_string_literal: true

module Monster
  TYPES = { orc: 'orc', ogre: 'ogre', pig: 'pig', cyclops: 'cyclops', chicken: 'chicken', cow: 'cow' }.freeze

  def self.new(keys)
    Item.new(**keys)
  end

  Item = Struct.new(:code)
end
