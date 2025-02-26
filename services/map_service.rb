# frozen_string_literal: true

module MapService
  class << self
    def items
      @items ||= pull
    end

    def monsters(code: nil)
      @monsters ||= non_empty.select { |map| map.type == Map::TYPES[:monster] && (!code || map.code == code) }
    end

    def monster(code: nil)
      monsters(code:).first
    end

    def resources(code: nil)
      @resources ||= non_empty.select { |map| map.type == Map::TYPES[:resource] && (!code || map.code == code) }
    end

    def resource(code: nil)
      resources(code:).first
    end

    def banks(code: nil)
      @banks ||= non_empty.select { |map| map.type == Map::TYPES[:bank] && (!code || map.code == code) }
    end

    def bank(code: nil)
      banks(code:).first
    end

    def npcs(code: nil)
      @npcs ||= non_empty.select { |map| map.type == Map::TYPES[:npc] && (!code || map.code == code) }
    end

    def npc(code: nil)
      npcs(code:).first
    end

    def tasks_masters(code: nil)
      @tasks_masters ||= non_empty.select { |map| map.type == Map::TYPES[:tasks_master] && (!code || map.code == code) }
    end

    def tasks_master(code: nil)
      tasks_masters(code:).first
    end

    def workshops(code: nil)
      @workshops ||= non_empty.select { |map| map.type == Map::TYPES[:workshop] && (!code || map.code == code) }
    end

    def workshop(code: nil)
      workshops(code:).first
    end

    def grand_exchanges(code: nil)
      @grand_exchanges ||=
        non_empty.select { |map| map.type == Map::TYPES[:grand_exchange] && (!code || map.code == code) }
    end

    def grand_exchange(code: nil)
      grand_exchanges(code:).first
    end

    def non_empty
      items.reject { |map| map.type.nil? }
    end

    private

    def pull
      API::Action.new.maps
    end
  end
end
