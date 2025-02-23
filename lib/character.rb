# frozen_string_literal: true

module Character
  def self.new(keys)
    keys[:inventory] = keys[:inventory].map { |item| InventoryItem.new(item) }
    Item.new(**keys)
  end
  Item =
    Struct.new(
      :account,
      :alchemy_level,
      :alchemy_max_xp,
      :alchemy_xp,
      :amulet_slot,
      :artifact1_slot,
      :artifact2_slot,
      :artifact3_slot,
      :attack_air,
      :attack_earth,
      :attack_fire,
      :attack_water,
      :bag_slot,
      :body_armor_slot,
      :boots_slot,
      :cooking_level,
      :cooking_max_xp,
      :cooking_xp,
      :cooldown,
      :cooldown_expiration,
      :critical_strike,
      :dmg,
      :dmg_air,
      :dmg_earth,
      :dmg_fire,
      :dmg_water,
      :fishing_level,
      :fishing_max_xp,
      :fishing_xp,
      :gearcrafting_level,
      :gearcrafting_max_xp,
      :gearcrafting_xp,
      :gold,
      :haste,
      :helmet_slot,
      :hp,
      :inventory,
      :inventory_max_items,
      :jewelrycrafting_level,
      :jewelrycrafting_max_xp,
      :jewelrycrafting_xp,
      :leg_armor_slot,
      :level,
      :max_hp,
      :max_xp,
      :mining_level,
      :mining_max_xp,
      :mining_xp,
      :name,
      :prospecting,
      :res_air,
      :res_earth,
      :res_fire,
      :res_water,
      :ring1_slot,
      :ring2_slot,
      :rune_slot,
      :shield_slot,
      :skin,
      :speed,
      :task,
      :task_progress,
      :task_total,
      :task_type,
      :utility1_slot,
      :utility1_slot_quantity,
      :utility2_slot,
      :utility2_slot_quantity,
      :weapon_slot,
      :weaponcrafting_level,
      :weaponcrafting_max_xp,
      :weaponcrafting_xp,
      :wisdom,
      :woodcutting_level,
      :woodcutting_max_xp,
      :woodcutting_xp,
      :x,
      :xp,
      :y
    ) do
      def update(keys)
        keys.each { |key, value| self[key] = value }
        self
      end

      def move(x:, y:) # rubocop:disable Naming/MethodParameterName
        api.move(x:, y:)
      end

      def cooldown_expiration
        Time.new(self[:cooldown_expiration]).utc
      end

      private

      def api
        API::Action.new(character: self)
      end
    end
end
