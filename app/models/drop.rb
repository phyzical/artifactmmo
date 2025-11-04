# frozen_string_literal: true

module Drop
  def self.new(keys)
    Thing.new(**keys)
  end

  Thing =
    Struct.new(:code, :rate, :min_quantity, :max_quantity, :quantity) do
      def overview
        "#{"Code: #{code}," if code}#{" Rate: #{rate}," if rate}" \
          "#{" Min: #{min_quantity}," if min_quantity}#{" Max: #{max_quantity}," if max_quantity}" \
          "#{" Quantity: #{quantity}," if quantity}"
      end
    end
end
