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
        character.fight(code: Monsters::Monster::CODES[:chicken])
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
#  - make some loose algo to workout how chance of winning against a monster
#  - add multi threading for queue so that all characters can run at the same time might not be worth the complexity to save like ~3 seconds tops
