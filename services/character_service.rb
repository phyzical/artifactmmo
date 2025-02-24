# frozen_string_literal: true

module CharacterService
  class << self
    def characters
      @characters ||= pull
    end

    def update(values)
      find_by_name(values[:name])&.update(values)
    end

    def find_by_name(name)
      characters.find { |character| character.name == name }
    end

    private

    def pull
      API::Action.new.characters
    end
  end
end
