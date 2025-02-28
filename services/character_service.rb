# frozen_string_literal: true

module CharacterService
  class << self
    def init
      @init ||= pull
    end

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
      API::Action.new.characters
    end
  end
end
