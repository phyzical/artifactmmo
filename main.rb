# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'helpers', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'models', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'services', '**', '*.rb')].each { |file| require file }

def run
  Dir[File.join(__dir__, 'services', '*.rb')].each do |file|
    service_class = file.split('/').last.gsub('.rb', '').snake_to_camel
    Object.const_get(service_class).init
  end

  action_index = 0
  loop = 0
  loop_count = 20
  loop do
    # TODO: this is inefficient, we should be able to run all characters at the same time
    # Also we wait for empty it should be if char X empty reqeue not all empty as other chars sit in downtime
    if API::QueueService.empty?
      actions = [
        ->(character) { character.fight(code: Monsters::Monster::CODES[:chicken]) },
        ->(character) { character.mine(code: Resource::MINING_CODES[:copper_rocks]) },
        ->(character) { character.woodcut(code: Resource::WOODCUTTING_CODES[:ash_tree]) },
        ->(character) { character.fish(code: Resource::FISHING_CODES[:gudgeon_fishing_spot]) },
        ->(character) { character.herb(code: Resource::ALCHEMY_CODES[:sunflower_field]) }
      ]
      CharacterService.characters.each do |character|
        character.new_task
        actions[action_index].call(character)
      end
      loop += 1
      next unless (loop % loop_count).zero?
      loop = 0
      action_index += 1
      action_index = 0 if action_index == actions.length
    end
    API::QueueService.process
  end
end

begin
  run
rescue StandardError => e
  Logs.log(type: :pp, log: API::QueueService.responses.last, error: true)
  Logs.log(type: :pp, log: e.backtrace.map { |x| x.gsub('/app', '') }, error: true)
  raise e
end

#  TODOS
#  - make some loose algo to workout next best type to action when we call a skill
#  - add multi threading for queue so that all characters can run at the same time might not be worth the complexity to save like ~3 seconds tops
