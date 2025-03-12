# frozen_string_literal: true

module BankService
  class << self
    def bank
      return @bank if @bank
      @bank = pull
      @bank.items = pull_items
    end

    alias init bank

    def update_items(bank_items:)
      @bank.items = bank_items.map { |item| Characters::Item.new(**item) }
    end

    def update_gold(quantity:)
      @bank.gold = quantity
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
