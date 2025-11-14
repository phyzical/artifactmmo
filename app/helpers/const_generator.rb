# frozen_string_literal: true

require 'json'
require 'fileutils'

# Read the JSON file
module ConstGenerator
  DIR_PATH = Dir.pwd.freeze
  CACHE_PATH = "#{DIR_PATH}/cache".freeze
  APP_PATH = "#{DIR_PATH}/app".freeze
  CONSTANTS_PATH = "#{APP_PATH}/constants".freeze

  def self.generate_all
    return unless ENV['CONST_GENERATION'] == 'true'
    resources = {
      achievements: [:type],
      maps: %i[layer],
      monsters: %i[code type],
      items: %i[code type],
      npcs: [:type],
      npc_items: [:code]
    }

    resources.each { |resource, keys| keys.each { |key| generate(resource:, key:) } }
    system('rake lint_fix')
  end

  def self.generate(resource:, key:)
    puts "Generating constants for #{resource} - #{key}..."
    file_paths = Dir.glob("#{CACHE_PATH}/#{resource}-page-*.json")
    raise "No files found for resource: #{resource}" if file_paths.empty?
    const_hash = {}
    file_paths.sort!.each do |file_path|
      data = JSON.parse(File.read(file_path), symbolize_names: true)

      data[:data].each do |item|
        const_value = item[key.to_sym]
        const_hash[const_value.to_sym] = const_value
      end
    end

    const_definition = "  #{key.upcase}S = #{const_hash.inspect}.freeze"
    dir = "#{CONSTANTS_PATH}/#{resource}"
    FileUtils.mkdir_p(dir)
    file = "#{dir}/#{key}s.rb"
    File.write(file, <<~RUBY)
    # frozen_string_literal: true
    
    # rubocop:disable Metrics/CollectionLiteralLength
    # This file is auto-generated. Do not edit manually.
    module #{resource.to_s.split('_').map(&:capitalize).join}
      module Constants
        #{const_definition}
      end
    end
    # rubocop:enable Metrics/CollectionLiteralLength
    RUBY

    load file
  end
end
