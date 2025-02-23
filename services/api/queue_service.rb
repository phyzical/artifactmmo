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
          action = actions.slice!(index)
          result = action.handle
          actions.insert(index, action) if result == RESPONSE_CODES[:cooldown]
        end
      end

      def add(action)
        actions << action
      end

      private

      def next_action_index_not_in_cooldown
        actions.find_index { |action| !action.character.on_cooldown? } || 0
      end
    end
end
