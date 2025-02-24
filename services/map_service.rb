# frozen_string_literal: true

module MapService
  class << self
    def maps
      @maps ||= pull
    end

    def monsters(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:monster] && (!code || map.code == code) }
    end

    def resources(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:resource] && (!code || map.code == code) }
    end

    def banks(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:bank] && (!code || map.code == code) }
    end

    def npcs(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:npc] && (!code || map.code == code) }
    end

    def tasks_masters(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:tasks_master] && (!code || map.code == code) }
    end

    def workshops(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:workshop] && (!code || map.code == code) }
    end

    def grand_exchanges(code: nil)
      non_empty.select { |map| map.type == Map::TYPES[:grand_exchange] && (!code || map.code == code) }
    end

    def non_empty
      maps.reject { |map| map.type.nil? }
    end

    private

    def pull
      API::Action.new.maps
    end
  end
end
