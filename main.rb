# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'models', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'services', '**', '*.rb')].each { |file| require file }

characters = CharacterService.all.characters
maps = MapService.all.non_empty_maps

action_queue = API::QueueService.new

characters.each do |character|
  action_queue.add(character.move(x: 2, y: 0))
  action_queue.add(character.move(x: 2, y: 2))
  action_queue.add(character.move(x: 0, y: 2))
  action_queue.add(character.move(x: 0, y: 0))
end

action_queue.process
