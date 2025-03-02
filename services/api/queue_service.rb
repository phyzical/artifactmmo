# frozen_string_literal: true

module API
  module QueueService
    MAX_HISTORY_SIZE = 100

    DEFAULT_ACTIONS = [
      ->(character) { character.fight(code: Monsters::Monster::CODES[:chicken]) },
      ->(character) { character.mine(code: Resource::MINING_CODES[:copper_rocks]) },
      ->(character) { character.woodcut(code: Resource::WOODCUTTING_CODES[:ash_tree]) },
      ->(character) { character.fish(code: Resource::FISHING_CODES[:gudgeon_fishing_spot]) },
      ->(character) { character.herb(code: Resource::ALCHEMY_CODES[:sunflower_field]) }
    ].freeze
    LOOP_COUNT = 20
    COOLDOWN_SAFETY_TIME = 0.1

    class << self
      def actions
        @actions ||= []
      end

      def responses
        @responses ||= []
      end

      def start
        action_index = 0
        loop = 0
        loop do
          # TODO: this is inefficient, we should be able to run all characters at the same time
          # Also we wait for empty it should be if char X empty reqeue not all empty as other chars sit in downtime
          if empty?
            CharacterService.characters.each do |character|
              character.new_task
              DEFAULT_ACTIONS[action_index].call(character)
            end
            loop += 1
            next unless (loop % LOOP_COUNT).zero?
            loop = 0
            action_index += 1
            action_index = 0 if action_index == DEFAULT_ACTIONS.length
          end
          process
        end
      end

      def handle_action(action:)
        ACTIONS[action.action][:add_to_queue] ? add(action:) : run(action:)
      end

      private

      def empty?
        actions.empty?
      end

      def process
        while actions.any?
          index = next_action_index_not_in_cooldown

          if index.nil?
            Logs.log(
              type: :puts,
              log: [
                "everyone is on cooldown, waiting on the lowest cooldown #{lowest_cooldown} seconds",
                CharacterService.character_cooldowns_text
              ].join("\n"),
              info: true
            )
            sleep(lowest_cooldown)
            next
          end
          action = actions.slice!(index)
          next if action.move_redundant?
          run(action:)
          if responses.last.code == Response::CODES[:character_in_cooldown]
            actions.insert(index, action)
          else
            last_response_data_log(prefix: "#{action.character_log} Completed #{action.action}\n")
          end
        end
      end

      def last_response_data_log(prefix:)
        last_response = responses.last
        data = last_response.data
        character_text = last_response.action.character_log
        return if data == []
        unless data.first.respond_to?(:overview)
          data = data.first if data.length == 1
          return Logs.log(type: :puts, log: "#{prefix}#{character_text}#{data}") if data.is_a?(String)
          Logs.log(type: :puts, log: prefix)
          return Logs.log(type: :pp, log: data)
        end
        Logs.log(type: :puts, log: "#{prefix}#{character_text}#{data.map(&:overview).join("\n")}")
      end

      def add(action:)
        actions.push(action)
      end

      def run(action:)
        begin
          action.handle
        ensure
          responses.push(*action.responses)
        end
        clean_history
        action.data
      end

      def clean_history
        diff = responses.length - MAX_HISTORY_SIZE
        @responses = responses.slice(diff - 1, responses.length) if diff.positive?
      end

      def next_action_index_not_in_cooldown
        actions.find_index { |action| !action.character.on_cooldown? }
      end

      def lowest_cooldown
        actions.map { |action| action.character.current_cooldown }.min + COOLDOWN_SAFETY_TIME
      end
    end
  end
end
