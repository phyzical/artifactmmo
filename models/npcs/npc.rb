# frozen_string_literal: true

module NPCs
  module NPC
    TYPES = { merchant: 'merchant' }.freeze

    def self.new(keys)
      Thing.new(**keys)
    end

    Thing = Struct.new(:name, :code, :description, :type, :items)
  end
end
