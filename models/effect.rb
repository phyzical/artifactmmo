# frozen_string_literal: true

module Effect
  def self.new(keys)
    Thing.new(**keys)
  end

  Thing = Struct.new(:code, :value)
end
