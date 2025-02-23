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
bank_tile_coords = maps.banks.first.to_h.slice(:x, :y)
chicken_tile_coords = maps.monsters(code: Monster::TYPES[:chicken]).first.to_h.slice(:x, :y)

empty_inventories = -> do
  characters.each do |character|
    next unless character.inventory_full?
    puts "#{character.name} inventory is full"
    action_queue.add(character.move(**bank_tile_coords)) if character.to_h.slice(:x, :y) != bank_tile_coords
    action_queue.add(character.deposit_all)
  end
end

chicken_massacre = -> do
  characters.each do |character|
    action_queue.add(character.rest) if character.hp < character.max_hp
    action_queue.add(character.move(**chicken_tile_coords)) if character.to_h.slice(:x, :y) != chicken_tile_coords
    action_queue.add(character.fight)
  end
end

loop do
  if action_queue.empty?
    empty_inventories.call
    chicken_massacre.call
  end
  action_queue.process
end
