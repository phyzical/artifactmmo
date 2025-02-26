# frozen_string_literal: true

module BankService
  class << self
    def bank
      return @bank if @bank
      @bank = pull
      @bank.items = pull_items
    end

    alias items bank

    def update_items(bank_items:)
      @bank.items = bank_items.map { |item| InventoryItem.new(**item) }
    end

    private

    def pull
      API::Action.new.bank.first
    end

    def pull_items
      API::Action.new.bank_items
    end
  end
end
