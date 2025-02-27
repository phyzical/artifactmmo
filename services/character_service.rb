# frozen_string_literal: true

module CharacterService
  class << self
    def items
      @items ||= pull
    end

    def update(values)
      find_by_name(values[:name])&.update(values)
    end

    def find_by_name(name)
      items.find { |character| character.name == name }
    end

    def character_cooldowns_text
      items
        .reduce('') { |acc, character| acc + "#{character.name}: #{character.current_cooldown} seconds, " }
        .chomp(', ')
    end

    private

    def pull
      API::Action.new.characters
    end
  end
end
