# frozen_string_literal: true

module Achievement
  TYPES = Achievements::Constants::TYPES

  def self.new(keys)
    keys[:reward] = Reward.new(gold: keys.delete(:rewards)[:gold])
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :type, :code, :description, :points, :target, :total, :reward)
end
