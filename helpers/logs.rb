# frozen_string_literal: true

module Logs
  def self.log(keys)
    Log.new(**keys).post
  end

  @last_color = nil
  @preserve_color = nil

  Log =
    Struct.new(:log, :type, :error, :info, :start) do
      def post
        reset_stored_colors
        color = random_color
        puts "#{color}#{log}" if type == :puts
        pp log if type == :pp
      end

      def reset_stored_colors
        @last_color = nil if info || error
        @preserve_color = nil if info || error || start
      end

      def random_color
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
