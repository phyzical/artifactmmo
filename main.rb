# frozen_string_literal: true

require 'dotenv/load'
require 'uri'
require 'net/http'
require 'active_support/all'
require 'prettyprint'
Dir[File.join(__dir__, 'lib', '**', '*.rb')].each { |file| require file }

characters = API::Action.new.characters.map { |character| Character.new(**character) }

moves = [{ x: 1, y: 0 }, { x: 1, y: 1 }, { x: 0, y: 1 }, { x: 0, y: 0 }]
characters.each { |character| moves.each { |move| character.move(**move) } }
