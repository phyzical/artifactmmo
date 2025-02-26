# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'models', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'services', '**', '*.rb')].each { |file| require file }

def run
  %i[CharacterService MonsterService ItemsService MapService].map { |service| Object.const_get(service).items }
  characters = CharacterService.items

  loop do
    if API::QueueService.empty?
      characters.each { |character| character.fight(code: Monsters::Monster::CODES[:chicken]) }
    end
    API::QueueService.process
  end
end

begin
  run
rescue StandardError => e
  pp API::QueueService.responses.last
  pp e
  pp e.backtrace.map { |x| x.gsub('/app', '') }
end
