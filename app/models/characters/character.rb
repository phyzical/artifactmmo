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
        :y,
        :initiative,
        :threat,
        :effects,
        :layer,
        :map_id
      ) do
        def update(keys)
          Thing.process_keys(keys:).each { |key, value| self[key] = value }
          self
        end

        def overview
          "Name: #{name}, Level: #{level}, XP: #{xp}, HP: #{hp}, Gold: #{gold}, Position: #{position}," \
            "\n     #{skills.map(&:overview).join("\n     ")}"
        end

        def move(x:, y:) # rubocop:disable Naming/MethodParameterName
          api.move(x:, y:)
        end

        def fight(code: nil)
          inventory_check
          rest_check
          code ||= MonstersService.by_level(level:).code
          move(**MapsService.monster(code:).position)
          api.fight
        end

        def inventory_check
          return unless inventory_full?
          deposit_all
          Logs.log(type: :puts, log: "#{name} inventory is full")
        end

        def rest_check
          return if hp > (max_hp / 4)
          api.rest
        end

        def mine(code: nil)
          inventory_check
          code ||= ResourcesService.mining_by_level(level: mining.level).code
          move(**MapsService.resource(code:).position)
          api.gather
        end

        def woodcut(code: nil)
          inventory_check
          code ||= ResourcesService.woodcutting_by_level(level: woodcutting.level).code
          move(**MapsService.resource(code:).position)
          api.gather
        end

        def fish(code: nil)
          inventory_check
          code ||= ResourcesService.fishing_by_level(level: fishing.level).code
          move(**MapsService.resource(code:).position)
          api.gather
        end

        def herb(code: nil)
          inventory_check
          code ||= ResourcesService.alchemy_by_level(level: alchemy.level).code
          move(**MapsService.resource(code:).position)
          api.gather
        end

        def deposit(code:, quantity:)
          bank = MapsService.bank
          move(**bank.position)
          api.deposit(code:, quantity:)
        end

        def deposit_gold(quantity: gold)
          return if quantity.zero?
          deposit(code: ::Item.code(code: :gold), quantity:)
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

        def mining
          skills.find { |skill| skill.code == Skills::Skill::CODES[:mining] }
        end

        def woodcutting
          skills.find { |skill| skill.code == Skills::Skill::CODES[:woodcutting] }
        end

        def fishing
          skills.find { |skill| skill.code == Skills::Skill::CODES[:fishing] }
        end

        def cooking
          skills.find { |skill| skill.code == Skills::Skill::CODES[:cooking] }
        end

        def alchemy
          skills.find { |skill| skill.code == Skills::Skill::CODES[:alchemy] }
        end

        def gearcrafting
          skills.find { |skill| skill.code == Skills::Skill::CODES[:gearcrafting] }
        end

        def jewelrycrafting
          skills.find { |skill| skill.code == Skills::Skill::CODES[:jewelrycrafting] }
        end

        def weaponcrafting
          skills.find { |skill| skill.code == Skills::Skill::CODES[:weaponcrafting] }
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
            keys = process_effects(keys:)
            process_slots(keys:)
          end

          def process_inventory(keys:)
            keys[:inventory] = keys[:inventory].map { |item| Item.new(**item) }
            keys
          end

          def process_effects(keys:)
            keys[:effects] = keys[:effects].map { |effect| Effect.new(**effect) }
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
                code: skill,
                level_xp: keys.delete(:"#{skill}_xp"),
                level: keys.delete(:"#{skill}_level"),
                level_up_xp: keys.delete(:"#{skill}_max_xp")
              )
            end
            keys
          end

          def process_slots(keys:)
            keys[:slots] = Item::TYPES.map do |_code, code|
              Item.new(code:, slot: keys.delete(:"#{code}_slot"), quantity: keys.delete(:"#{code}_slot_quantity"))
            end
            keys
          end
        end
      end
  end
end
