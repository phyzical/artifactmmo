# frozen_string_literal: true

module InventoryItem
  def self.new(keys)
    Item.new(**keys)
  end
  Item = Struct.new(:slot, :code, :quantity)
end
