# frozen_string_literal: true

module Characters
  module Character
    class << self
      def new(keys)
        Thing.new(**Thing.process_keys(keys:))
      end
    end

    Thing =
      Struct.new(
        :account,
        :attack_air,
        :attack_earth,
        :attack_fire,
        :attack_water,
        :cooldown,
        :cooldown_expiration,
        :critical_strike,
        :dmg,
        :dmg_air,
        :dmg_earth,
        :dmg_fire,
        :dmg_water,
        :gold,
        :haste,
        :hp,
        :inventory,
        :inventory_max_items,
        :level,
        :max_hp,
        :max_xp,
        :name,
        :prospecting,
        :res_air,
        :res_earth,
        :res_fire,
        :res_water,
        :slots,
        :skills,
        :skin,
        :speed,
        :task,
        :wisdom,
        :x,
        :xp,
        :y
      ) do
        def update(keys)
          Thing.process_keys(keys:).each { |key, value| self[key] = value }
          self
        end

        def move(x:, y:) # rubocop:disable Naming/MethodParameterName
          api.move(x:, y:)
        end

        def fight(code:)
          inventory_check
          rest
          monster = MapsService.monster(code:)
          move(**monster.position)
          api.fight
        end

        def inventory_check
          return unless inventory_full?
          deposit_all
          Logs.log(type: :puts, log: "#{name} inventory is full")
        end

        def rest
          return if hp >= max_hp
          api.rest
        end

        def mine(code:)
          inventory_check
          mine = MapsService.resource(code:)
          move(**mine.position)
          api.gather
        end

        def woodcut(code:)
          inventory_check
          woodcut = MapsService.resource(code:)
          move(**woodcut.position)
          api.gather
        end

        def fish(code:)
          inventory_check
          fish = MapsService.resource(code:)
          move(**fish.position)
          api.gather
        end

        def herb(code:)
          inventory_check
          herb = MapsService.resource(code:)
          move(**herb.position)
          api.gather
        end

        def deposit(code:, quantity:)
          bank = MapsService.bank
          move(**bank.position)
          api.deposit(code:, quantity:)
        end

        def deposit_gold(quantity: gold)
          return if quantity.zero?
          deposit(code: Item.code(code: :gold), quantity:)
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

        def new_task
          return if task.present?
          task_master = MapsService.tasks_master
          move(**task_master.position) if position != task_master.position
          api.task
        end

        def inventory_full?
          inventory_counts_by_items.values.sum >= (inventory_max_items - 5) ||
            inventory.none? { |item| item.code.empty? }
        end

        def position
          { x:, y: }
        end

        def deposit_all
          deposit_all_items.push(deposit_gold)
        end

        private

        def deposit_all_items
          inventory_counts_by_items.map { |code, quantity| deposit(code:, quantity:) }
        end

        def inventory_items
          inventory.reject { |x| x.code.empty? }
        end

        def inventory_counts_by_items
          inventory_items.group_by(&:code).transform_values { |items| items.sum(&:quantity) }
        end

        def api
          API::Action.new(character_name: name)
        end

        class << self
          def process_keys(keys:)
            keys = process_inventory(keys:)
            keys = process_task_payload(keys:)
            keys = process_skills(keys:)
            process_slots(keys:)
          end

          def process_inventory(keys:)
            keys[:inventory] = keys[:inventory].map { |item| Item.new(**item) }
            keys
          end

          def process_task_payload(keys:)
            if keys[:task].blank?
              keys[:task] = nil
              keys.except!(:task_progress, :task_total, :task_type)
              return keys
            end
            keys.delete(:task_type)
            keys[:task] = TasksService
              .task(code: keys.delete(:task))
              .dup
              .update(progress: keys.delete(:task_progress), total: keys.delete(:task_total))
            keys
          end

          def process_skills(keys:)
            keys[:skills] = Skills::Skill::CODES.map do |_code, skill|
              Skills::Skill.new(
                level_xp: keys.delete(:"#{skill}_xp"),
                level: keys.delete(:"#{skill}_level"),
                level_up_xp: keys.delete(:"#{skill}_max_xp")
              )
            end
            keys
          end

          def process_slots(keys:)
            keys[:slots] = Item::SLOTS.map do |_code, code|
              Item.new(code:, slot: keys.delete(:"#{code}_slot"), quantity: keys.delete(:"#{code}_slot_quantity"))
            end
            keys
          end
        end
      end
  end
end
