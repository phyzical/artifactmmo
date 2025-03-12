# frozen_string_literal: true

module NpcsService
  class << self
    def init
      @init ||= pull
    end

    def npc(code:)
      npcs(code:)&.first
    end

    def npcs(code: nil)
      @npcs ||= init.group_by(&:code)
      @npcs[code] || init
    end

    def merchants(code: nil)
      @merchants ||= init.select { |npc| npc.type == NPC::TYPES[:merchant] }.group_by(&:code)
      @merchants[code] || @merchants.values.flatten
    end

    def merchant(code:)
      merchants(code:)&.first
    end

    private

    def pull
      API::Action.new.npcs.map do |npc|
        npc.items = API::Action.new.npc_items(code: npc.code)
        npc
      end
    end
  end
end
