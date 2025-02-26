# frozen_string_literal: true

Character =
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
    def initialize(keys)
      keys[:inventory] = process_inventory(inventory: keys[:inventory])
      super(**keys)
    end

    def update(keys)
      keys[:inventory] = process_inventory(inventory: keys[:inventory])
      keys.each { |key, value| self[key] = value }
      self
    end

    def move(x:, y:) # rubocop:disable Naming/MethodParameterName
      api.move(x:, y:)
    end

    def fight(code:)
      if inventory_full?
        deposit_all
        puts "#{character.name} inventory is full"
      end
      rest
      monster = MapService.monster(code:)
      move(**monster.position) if position != monster.position
      api.fight
    end

    def rest
      return if hp >= max_hp
      api.rest
    end

    def deposit(code:, quantity:)
      bank_position = MapService.bank.position
      move(**bank_position) if position != bank_position
      api.deposit(code:, quantity:)
    end

    def deposit_gold(quantity: gold)
      deposit(code: InventoryItem::CODES[:gold], quantity:)
    end

    def cooldown_expiration
      Time.new(self[:cooldown_expiration]).utc
    end

    def on_cooldown?
      current_cooldown.positive?
    end

    def current_cooldown
      cooldown_expiration - Time.now.utc
    end

    def inventory_full?
      inventory_counts_by_items.values.sum >= (inventory_max_items - 5) || inventory.none? { |item| item.code.empty? }
    end

    def position
      { x:, y: }
    end

    def deposit_all
      deposit_all_items.push(deposit_gold)
    end

    private

    def deposit_all_items
      inventory_counts_by_items.map { |code, quantity| api.deposit(code:, quantity:) }
    end

    def inventory_items
      inventory.reject { |x| x.code.empty? }
    end

    def inventory_counts_by_items
      inventory_items.group_by(&:code).transform_values { |items| items.sum(&:quantity) }
    end

    def process_inventory(inventory:)
      inventory.map { |item| InventoryItem.new(**item) }
    end

    def api
      API::Action.new(character_name: name)
    end
  end
