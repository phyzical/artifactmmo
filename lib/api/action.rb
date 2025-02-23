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
    Struct.new(:character, :action) do
      delegate :name, to: :character, prefix: true, allow_nil: true

      def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
        go(action: :move, body: { x:, y: })
      end

      def characters
        go(action: :characters)
      end

      private

      def go(action:, body: {})
        self.action = action
        wait_for_cooldown
        puts "#{character_name}: #{action} #{body}"
        request = request(body:)
        perform(request:)
      end

      def api_key
        ENV['API_KEY']
      end

      def request(body: {})
        url = URI("#{BASE_URL}/#{uri}")
        request = type.new(url)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = "Bearer #{api_key}"
        request.body = JSON.generate(body)
        request
      end

      def perform(request:)
        http = Net::HTTP.new(request.uri.host, request.uri.port)
        http.use_ssl = true
        response = http.request(request)
        case response.code.to_i
        when 200
          payload = JSON.parse(response.read_body, symbolize_names: true)[:data]
          return payload if character.nil?
          character&.update(payload[:character])
        when RESPONSE_CODES[:no_move]
          puts "#{character_name}: already on tile"
        else
          puts "Error: #{response.code}"
          raise response.read_body
        end
      end

      # TODO: we need some sort of queuing system to handle this also async maybe?
      # could maybe instead boot it out and go to next guys job
      def wait_for_cooldown
        return unless character

        current_datetime = Time.now.utc
        cooldown_expiration = character.cooldown_expiration
        return if current_datetime > cooldown_expiration
        sleep_time = (cooldown_expiration - current_datetime + 1).to_i
        puts "#{character_name}: sleeping for #{sleep_time} seconds"
        sleep(sleep_time)
      end

      def uri
        ACTIONS[action][:uri].gsub(CHARACTER_NAME_KEY, character_name || '')
      end

      def type
        ACTIONS[action][:type]
      end
    end
end
