# frozen_string_literal: true

module Condition
  def self.new(keys)
    Thing.new(**keys)
  end

  OPERATORS = {
    eq: 'eq',
    ne: 'ne',
    gt: 'gt',
    lt: 'lt',
    cost: 'cost',
    has_item: 'has_item',
    achievement_unlocked: 'achievement_unlocked'
  }.freeze

  def self.operator(operator:)
    OPERATORS[operator.to_sym] || raise(ArgumentError, "Invalid operator: #{operator}")
  end

  Thing =
    Struct.new(:operator, :code, :value) do
      def initialize(keys)
        keys[:operator] = Condition.operator(operator: keys.delete(:operator))
        super(**keys)
      end

      def overview
        "Operator: #{operator}, Code: #{code}, Value: #{value}"
      end
    end
end
