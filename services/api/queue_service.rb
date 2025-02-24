# frozen_string_literal: true

module API
  module QueueService
    class << self
      def actions
        @actions ||= []
      end

      def process
        while actions.any?
          index = next_action_index_not_in_cooldown
          if index.nil?
            puts "everyone is on cooldown, waiting on the lowest cooldown #{lowest_cooldown} seconds"
            characters.each do |character|
              puts "#{character.name}: is on cooldown for #{character.current_cooldown} seconds"
            end
            sleep(lowest_cooldown + 0.1)
            next
          end
          action = actions.slice!(index)
          result = action.handle
          actions.insert(index, action) if result == RESPONSE_CODES[:cooldown]
        end
      end

      def add(actions_to_add)
        actions.push(*(actions_to_add.is_a?(Action) ? [actions_to_add] : actions_to_add))
      end

      def empty?
        actions.empty?
      end

      private

      def next_action_index_not_in_cooldown
        actions.find_index { |action| !action.character.on_cooldown? }
      end

      def characters
        CharacterService.items
      end

      def lowest_cooldown
        actions.map { |action| action.character.current_cooldown }.min
      end
    end
  end
end
