# frozen_string_literal: true

module Logs
  class << self
    # TODO: maybe a struct is better suited?
    def log(log:, type:, error: nil, info: nil, start: false)
      reset_stored_colors(info:, error:, start:)
      puts "#{random_color(info:, error:, start:)}#{log}" if type == :puts
      pp "#{random_color(info:, error:, start:)}#{log}" if type == :pp
    end

    def reset_stored_colors(info:, error:, start:)
      @last_color = nil if info || error
      @preserve_color = nil if info || error || start
    end

    def random_color(info:, error:, start:)
      info_color = "\e[33m" # Yellow
      return info_color if info

      error_color = "\e[31m" # Red
      return error_color if error

      colors = [
        "\e[32m", # Green
        "\e[34m", # Blue
        "\e[35m", # Magenta
        "\e[36m", # Cyan
        "\e[37m" # White
      ]
      colors.delete(@last_color) if @last_color
      colors.delete(@preserve_color) if @preserve_color
      color = ((@preserve_color != @last_color) && @preserve_color) || colors.sample
      @last_color = color
      @preserve_color = color if start
    end
  end
end
