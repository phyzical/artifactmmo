# frozen_string_literal: true

module Event
  def self.new(keys)
    keys[:maps] = keys[:maps].map { |map| MapsService.find_by_position(**map) }
    keys[:type] = keys[:content][:type]
    keys[:content_code] = keys[:content][:code]
    keys.delete(:content)
    Thing.new(**keys)
  end

  Thing = Struct.new(:name, :type, :code, :maps, :skin, :duration, :rate, :content_code)
end
