# frozen_string_literal: true

module Task
  CODES = Characters::Skill::CODES

  TYPES = { monsters: 'monsters', items: 'items' }.freeze

  def self.new(keys)
    Thing.new(**Thing.process_keys(keys:))
  end

  Thing =
    Struct.new(:code, :type, :rewards, :total, :progress, :level, :min_quantity, :max_quantity, :skill) do
      def update(keys)
        Thing.process_keys(keys:).each { |key, value| self[key] = value }
      end

      def self.process_keys(keys:)
        keys[:rewards] = Reward.new(**keys[:rewards]) if keys[:rewards]
        keys
      end
    end
end
