# frozen_string_literal: true

module Npcs
  module Npc
    TYPES = Constants::TYPES
    def self.new(keys)
      Thing.new(**keys)
    end

    Thing = Struct.new(:name, :code, :description, :type, :items)
  end
end
