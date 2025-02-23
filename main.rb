# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'models', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'services', '**', '*.rb')].each { |file| require file }

characters = CharacterService.all.characters
maps = MapService.all

action_queue = API::QueueService.new
chicken_tile = maps.find_maps_by_monster_code(Monster::TYPES[:chicken]).first

chicken_massacre = -> do
  characters.each do |character|
    action_queue.add(character.move(**chicken_tile.to_h.slice(:x, :y)))
    action_queue.add(character.fight)
  end
end

loop do
  chicken_massacre.call if action_queue.empty?
  action_queue.process
end
