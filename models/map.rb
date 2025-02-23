# frozen_string_literal: true

Map =
  Struct.new(:name, :skin, :x, :y, :type, :code) do
    def initialize(keys)
      content = keys.delete(:content) || {}
      super(**content, **keys)
    end
  end
