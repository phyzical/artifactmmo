# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'models', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'services', '**', '*.rb')].each { |file| require file }

def run
  monsters = MonsterService.items
  items = ItemsService.items
  characters = CharacterService.items
  bank_tile_coords = MapService.banks.first.to_h.slice(:x, :y)
  chicken_tile_coords = MapService.monsters(code: Monsters::Monster::CODES[:chicken]).first.to_h.slice(:x, :y)

  #TODO: could we maybe make the action queue, queue this up if fight fails due to inventory being full?
  empty_inventories = -> do
    characters.each do |character|
      next unless character.inventory_full?
      puts "#{character.name} inventory is full"
      character.move(**bank_tile_coords) if character.to_h.slice(:x, :y) != bank_tile_coords
      character.deposit_all
    end
  end

  #TODO: could we maybe make this a list of tasks to perform? and just call process and it just spins through the list?
  chicken_massacre = -> do
    characters.each do |character|
      character.rest if character.hp < character.max_hp
      character.move(**chicken_tile_coords) if character.to_h.slice(:x, :y) != chicken_tile_coords
      character.fight
    end
  end

  loop do
    if API::QueueService.empty?
      empty_inventories.call
      chicken_massacre.call
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
