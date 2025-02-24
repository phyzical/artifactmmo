# frozen_string_literal: true

module Effect
  def self.new(keys)
    Item.new(**keys)
  end

  Item = Struct.new(:code, :value)
end
