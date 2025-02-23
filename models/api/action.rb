# frozen_string_literal: true

require_relative '../character'
require_relative '../map'

module API
  BASE_URL = 'https://api.artifactsmmo.com'

  CHARACTER_NAME_KEY = 'CHARACTER_NAME'
  ACTIONS = {
    move: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/move",
      type: Net::HTTP::Post
    },
    characters: {
      uri: 'my/characters',
      type: Net::HTTP::Get,
      model: Character
    },
    maps: {
      uri: 'maps',
      type: Net::HTTP::Get,
      model: Map
    }
  }.freeze

  RESPONSE_CODES = { no_move: 490, cooldown: 499 }.freeze

  Action =
    Struct.new(:character_name, :action, :request) do
      def character
        return if character_name.nil?
        CharacterService.all.find_by_name(character_name)
      end

      def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
        prepare(action: :move, body: { x:, y: })
      end

      def characters
        prepare(action: :characters)
      end

      def maps
        prepare(action: :maps)
      end

      def handle
        perform
      end

      private

      def prepare(action:, body: {})
        self.action = action
        prepare_request(body:)
        self
      end

      def api_key
        ENV['API_KEY']
      end

      def prepare_request(body: {})
        url = URI("#{BASE_URL}/#{uri}")
        self.request = type.new(url)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = "Bearer #{api_key}"
        request.body = JSON.generate(body)
      end

      def perform
        http = Net::HTTP.new(request.uri.host, request.uri.port)
        http.use_ssl = true
        page = 1
        loop do
          puts "#{character_name ? "#{character_name}: " : ''}#{action} page #{page}"
          request.uri.query = URI.encode_www_form(page:)
          response = http.request(request)
          handled_response = handle_response(response_code: response.code.to_i, response_body: response.body)
          page += 1
          pages = handled_response[:pages]
          break unless pages.present? && page < pages
        end
      end

      def handle_response(response_code:, response_body:)
        case response_code
        when 200
          handle_success(response_body:)
        when RESPONSE_CODES[:no_move]
          puts "#{character_name}: already on tile"
        when RESPONSE_CODES[:cooldown]
          puts "#{character_name}: on cooldown"
          RESPONSE_CODES[:cooldown]
        else
          puts "Error: #{response_code}"
          raise response_body
        end
      end

      def handle_success(response_body:)
        payloads = JSON.parse(response_body, symbolize_names: true)
        items = payloads[:data]
        response = payloads.slice(:page, :pages)
        if model.present? && items.is_a?(Array)
          response[:items] = items.map { |payload| model.new(**payload) }
        elsif model.present?
          response[:items] = model.new(**items)
        else
          CharacterService.all.update(items[:character])
        end
        response
      end

      def uri
        ACTIONS[action][:uri].gsub(CHARACTER_NAME_KEY, character_name || '')
      end

      def type
        ACTIONS[action][:type]
      end

      def model
        ACTIONS[action][:model]
      end
    end
end
