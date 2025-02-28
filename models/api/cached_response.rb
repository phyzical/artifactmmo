# frozen_string_literal: true

module API
  module CachedResponse
    def self.new(keys)
      Thing.new(**keys)
    end

    Thing = Struct.new(:code, :body)
  end
end
