# frozen_string_literal: true

class String
  def snake_to_camel
    split('_').map(&:capitalize).join
  end
end
