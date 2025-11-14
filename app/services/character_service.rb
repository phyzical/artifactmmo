# frozen_string_literal: true

module CharacterService
  class << self
    def init
      @init ||= pull
    end

    MAX = 5
    SKINS = %w[men1 men2 men3 women1 women2 women3].freeze

    alias characters init

    def update(values)
      find_by_name(values[:name])&.update(values)
    end

    def find_by_name(name)
      init.find { |character| character.name == name }
    end

    def character_cooldowns_text
      init
        .reduce('') { |acc, character| acc + "#{character.name}: #{character.current_cooldown} seconds, " }
        .chomp(', ')
    end

    private

    def pull
      characters = API::Action.new.characters
      return characters if characters.length == MAX
      characters
        .length
        .upto(MAX - 1) do |index|
          characters << API::Action.new.new_character(name: "Phyzical_#{index + 1}", skin: SKINS.sample)
        end
      API::Action.new.characters
    end
  end
end
