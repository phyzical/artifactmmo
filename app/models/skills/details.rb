# frozen_string_literal: true

module Skills
  module Details
    def self.new(keys)
      keys[:items] = keys[:items].map { |item| Drop.new(**item) }
      Thing.new(**keys)
    end

    Thing =
      Struct.new(:xp, :items) do
        def overview
          " XP: #{xp}, Items: #{items.map(&:overview).join(', ')}"
        end
      end
  end
end
