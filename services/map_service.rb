# frozen_string_literal: true

module MapService
  def self.all
    @all ||= List.new
  end
  List =
    Struct.new(:items) do
      def initialize
        super(items: pull)
      end

      private

      def pull
        API::Action.new.maps.handle
      end
    end
end
