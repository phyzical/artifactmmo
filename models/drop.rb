# frozen_string_literal: true

module Drop
  def self.new(keys)
    Thing.new(**keys)
  end

  Thing =
    Struct.new(:code, :rate, :min_quantity, :max_quantity, :quantity) do
      def overview
        "#{code ? "Code: #{code}," : ''}#{rate ? " Rate: #{rate}," : ''}" \
          "#{min_quantity ? " Min: #{min_quantity}," : ''}#{max_quantity ? " Max: #{max_quantity}," : ''}" \
          "#{quantity ? " Quantity: #{quantity}," : ''}"
      end
    end
end
