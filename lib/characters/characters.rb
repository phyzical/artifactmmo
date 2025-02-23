# frozen_string_literal: true

module Characters
  def self.all
    @all ||= List.new
  end
  List =
    Struct.new(:characters) do
      def initialize
        super(characters: pull.map { |character| Character.new(**character) })
      end

      def update(values)
        characters.find { |character| character.name == values[:name] }&.update(values)
      end

      def find_by_name(name)
        characters.find { |character| character.name == name }
      end

      private

      def pull
        API::Action.new.characters.handle
      end
    end
end
