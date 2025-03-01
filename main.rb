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

  loop do
    if API::QueueService.empty?
      CharacterService.characters.each do |character|
        character.new_task
        # character.fight(code: Monsters::Monster::CODES[:chicken])
        character.mine(code: Resource::MINING_CODES[:copper_rocks])
        # character.woodcut(code: Resource::WOODCUTTING_CODES[:dead_tree])
        # character.fish(code: Resource::FISHING_CODES[:shrimp_fishing_spot])
        # character.herb(code: Resource::ALCHEMY_CODES[:nettle])
      end
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
