# frozen_string_literal: true

module Drop
  def self.new(keys)
    Thing.new(**keys)
  end

  Thing =
    Struct.new(:code, :rate, :min_quantity, :max_quantity, :quantity) do
      def overview
        "Code: #{code},Rate: #{rate}, Min: #{min_quantity}, Max: #{max_quantity}, Quantity: #{quantity}"
      end
    end
end
