# frozen_string_literal: true

module API
  QueueService =
    Struct.new(:actions) do
      def initialize(keys = {})
        super(**keys)
        self.actions = []
      end

      def process
        while actions.any?
          index = next_action_index_not_in_cooldown
          if index.nil?
            puts "everyone is on cooldown, waiting #{lowest_cooldown} seconds"
            sleep(lowest_cooldown + 0.1)
            next
          end
          action = actions.slice!(index)
          result = action.handle
          actions.insert(index, action) if result == RESPONSE_CODES[:cooldown]
        end
      end

      def add(action)
        actions << action
      end

      def empty?
        actions.empty?
      end

      private

      def next_action_index_not_in_cooldown
        actions.find_index { |action| !action.character.on_cooldown? }
      end

      def lowest_cooldown
        actions.map { |action| action.character.current_cooldown }.min
      end
    end
end
