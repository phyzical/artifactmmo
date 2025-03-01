# frozen_string_literal: true

module Resource
  TYPES = { merchant: 'merchant' }.freeze

  def self.new(keys)
    keys[:drops] = keys[:drops].map { |drop| Drop.new(drop) }
    Thing.new(**keys)
  end

  Thing = Struct.new(:skill, :level, :drops, :code, :name)
end
