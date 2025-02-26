# frozen_string_literal: true

module API
  module QueueService
    class << self
      def actions
        @actions ||= []
      end

      def responses
        @responses ||= []
      end

      def process
        while actions.any?
          index = next_action_index_not_in_cooldown
          if index.nil?
            puts "everyone is on cooldown, waiting on the lowest cooldown #{lowest_cooldown} seconds"
            puts CharacterService.character_cooldowns_text
            sleep(lowest_cooldown + 0.1)
            next
          end
          action = actions.slice!(index)
          run(action:)
          if responses.last.code == Response::CODES[:character_in_cooldown]
            actions.insert(index, action)
          else
            puts "#{action.character_log}Completed #{action.action}"
            last_response_data_log
          end
        end
      end

      def handle_action(action:)
        ACTIONS[action.action][:add_to_queue] ? add(action:) : run(action:)
      end

      def empty?
        actions.empty?
      end

      private

      def last_response_data_log
        return if responses.last.data == []
        pp responses.last.data
      end

      def add(action:)
        actions.push(action)
      end

      def run(action:)
        action.handle
        responses.push(*action.responses)
        action.data
      end

      def next_action_index_not_in_cooldown
        actions.find_index { |action| !action.character.on_cooldown? }
      end

      def lowest_cooldown
        actions.map { |action| action.character.current_cooldown }.min
      end
    end
  end
end
