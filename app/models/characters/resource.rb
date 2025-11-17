# frozen_string_literal: true

module Characters
  module Resource
    SKILLS = Skills::Skill::CODES.slice(:mining, :woodcutting, :fishing, :alchemy).freeze
    TYPES = { merchant: 'merchant' }.freeze

    MINING_CODES = {
      copper_rocks: 'copper_rocks',
      coal_rocks: 'coal_rocks',
      gold_rocks: 'gold_rocks',
      strange_rocks: 'strange_rocks',
      mithril_rocks: 'mithril_rocks',
      iron_rocks: 'iron_rocks'
    }.freeze

    WOODCUTTING_CODES = {
      ash_tree: 'ash_tree',
      spruce_tree: 'spruce_tree',
      birch_tree: 'birch_tree',
      dead_tree: 'dead_tree',
      magic_tree: 'magic_tree',
      maple_tree: 'maple_tree'
    }.freeze

    FISHING_CODES = {
      gudgeon_fishing_spot: 'gudgeon_fishing_spot',
      shrimp_fishing_spot: 'shrimp_fishing_spot',
      trout_fishing_spot: 'trout_fishing_spot',
      bass_fishing_spot: 'bass_fishing_spot',
      salmon_fishing_spot: 'salmon_fishing_spot'
    }.freeze
    ALCHEMY_CODES = { glowstem: 'glowstem', sunflower_field: 'sunflower_field', nettle: 'nettle' }.freeze

    def self.new(keys)
      keys[:drops] = keys[:drops].map { |drop| Drop.new(drop) }
      Thing.new(**keys)
    end

    Thing = Struct.new(:skill, :level, :drops, :code, :name)
  end
end
