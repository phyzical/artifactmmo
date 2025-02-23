# frozen_string_literal: true

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
      type: Net::HTTP::Get
    }
  }.freeze

  RESPONSE_CODES = { no_move: 490, cooldown: 499 }.freeze

  Action =
    Struct.new(:character, :action, :request) do
      delegate :name, to: :character, prefix: true, allow_nil: true

      def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
        prepare(action: :move, body: { x:, y: })
      end

      def characters
        prepare(action: :characters)
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
        puts "#{character_name}: #{action} #{request.body}"
        http = Net::HTTP.new(request.uri.host, request.uri.port)
        http.use_ssl = true
        response = http.request(request)
        handle_response(response_code: response.code.to_i, response_body: response.body)
      end

      def handle_response(response_code:, response_body:)
        case response_code
        when 200
          payload = JSON.parse(response_body, symbolize_names: true)[:data]
          return payload if character.nil?
          character&.update(payload[:character])
        when RESPONSE_CODES[:no_move]
          puts "#{character_name}: already on tile"
          character
        when RESPONSE_CODES[:cooldown]
          puts "#{character_name}: on cooldown"
          RESPONSE_CODES[:cooldown]
        else
          puts "Error: #{response_code}"
          raise response_body
        end
      end

      def uri
        ACTIONS[action][:uri].gsub(CHARACTER_NAME_KEY, character_name || '')
      end

      def type
        ACTIONS[action][:type]
      end
    end
end
