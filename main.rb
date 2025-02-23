# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'lib', '**', '*.rb')].each { |file| require file }

characters = Characters.all.characters

action_queue = API::Queue.new

characters.each do |character|
  action_queue.add(character.move(x: 1, y: 0))
  action_queue.add(character.move(x: 1, y: 1))
  action_queue.add(character.move(x: 0, y: 1))
  action_queue.add(character.move(x: 0, y: 0))
end

action_queue.process
