# frozen_string_literal: true

module MapService
  def self.all
    @all ||= List.new
  end
  List =
    Struct.new(:maps) do
      def initialize
        super(maps: pull)
      end

      def non_empty_maps
        maps.reject { |map| map.type.nil? }
      end

      private

      def pull
        API::Action.new.maps.handle
      end
    end
end
