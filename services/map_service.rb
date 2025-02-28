# frozen_string_literal: true

module MapService
  class << self
    def items
      @items ||= pull
    end

    def monsters(code: nil)
      @monsters ||= maps_by_type[Locations::Map.type(type: :monster)].group_by(&:code)
      @monsters[code] || @monsters.values.flatten
    end

    def monster(code:)
      monsters(code:)&.first
    end

    def resources(code: nil)
      @resources ||= maps_by_type[Locations::Map.type(type: :resource)].group_by(&:code)
      @resources[code] || @resources.values.flatten
    end

    def resource(code:)
      resources(code:)&.first
    end

    def banks(code: nil)
      @banks ||= maps_by_type[Locations::Map.type(type: :bank)].group_by(&:code)
      @banks[code] || @banks.values.flatten
    end

    def bank(code: nil)
      banks(code:)&.first
    end

    def npcs(code: nil)
      @npcs ||= maps_by_type[Locations::Map.type(type: :npc)].group_by(&:code)
      @npcs[code] || @npcs.values.flatten
    end

    def npc(code:)
      npcs(code:)&.first
    end

    def tasks_masters(code: nil)
      @tasks_masters ||= maps_by_type[Locations::Map.type(type: :tasks_master)].group_by(&:code)
      @tasks_masters[code] || @tasks_masters.values.flatten
    end

    def tasks_master(code: nil)
      tasks_masters(code:)&.first
    end

    def workshops(code: nil)
      @workshops ||= maps_by_type[Locations::Map.type(type: :workshop)].group_by(&:code)
      @workshops[code] || @workshops.values.flatten
    end

    def workshop(code:)
      workshops(code:)&.first
    end

    def grand_exchanges(code: nil)
      @grand_exchanges ||= maps_by_type[Locations::Map.type(type: :grand_exchange)].group_by(&:code)
      @grand_exchanges[code] || @grand_exchanges.values.flatten
    end

    def grand_exchange(code: nil)
      grand_exchanges(code:)&.first
    end

    def non_empty
      @non_empty ||= items.reject { |map| map.type.nil? }
    end

    def maps_by_type
      @maps_by_type ||= non_empty.group_by(&:type)
    end

    def find_by_position(x:, y:) # rubocop:disable Naming/MethodParameterName
      @items.find { |map| map.x == x && map.y == y }
    end

    private

    def pull
      API::Action.new.maps
    end
  end
end
