# frozen_string_literal: true

module NPCsService
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

    private

    def pull
      API::Action.new.npcs
    end
  end
end
