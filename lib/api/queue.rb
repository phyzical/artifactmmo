# frozen_string_literal: true

module API
  Queue =
    Struct.new(:actions, :characters) do
      def initialize(keys)
        super(**keys)
        self.actions = []
      end

      # TODO: will need some sort of logic around getting the earliest action for a character to preserve order
      #   TODO: add some sort of logic to skip to known not in cooldown characters?
      def process
        while actions.any?
          action = actions.shift # { |action_| action_ == next_in_cooldown_action }
          result = action.handle
          actions << action if result == API::RESPONSE_CODES[:cooldown]
        end
      end

      def add(action)
        actions << action
      end

      private

      def next_character_not_in_cooldown
        characters.find { |action| !action[:character].cooldown? }.first
      end
    end
end
