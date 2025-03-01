# frozen_string_literal: true

module Logs
  class << self
    def log(keys)
      Log.new(**keys).post
    end

    def last_color(color = nil)
      @last_color = color if color || color == false
      @last_color
    end

    def preserve_color(color = nil)
      @preserve_color = color if color || color == false
      @preserve_color
    end
  end

  Log =
    Struct.new(:log, :type, :error, :info, :start) do
      def post
        reset_stored_colors
        puts "#{color}#{log}" if type == :puts
        pp log if type == :pp
      end

      def reset_stored_colors
        Logs.last_color(false) if info || error
        Logs.preserve_color(false) if info || error || start
      end

      def color
        info_color = "\e[33m" # Yellow
        return info_color if info

        error_color = "\e[31m" # Red
        return error_color if error

        random_color
      end

      def random_color
        colors = [
          "\e[32m", # Green
          "\e[34m", # Blue
          "\e[35m", # Magenta
          "\e[36m", # Cyan
          "\e[37m" # White
        ]

        colors.delete(Logs.last_color) if Logs.last_color
        color = ((Logs.preserve_color != Logs.last_color) && Logs.preserve_color) || colors.sample
        Logs.last_color(color)
        Logs.preserve_color(Logs.last_color) if start
      end
    end
end
