# frozen_string_literal: true

module Tasks
  module Task
    def self.new(keys)
      keys = keys[:task]
      keys[:rewards] = keys[:rewards].map { |reward| Reward.new(**reward) }
      Item.new(**keys)
    end

    Item = Struct.new(:code, :type, :total, :rewards)
  end
end
