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
    },
    fight: {
      uri: 'my/CHARACTER_NAME/action/fight',
      type: Net::HTTP::Post
    }
  }.freeze

  RESPONSE_CODES = { no_move: 490, cooldown: 499 }.freeze

  Action =
    Struct.new(:character_name, :action, :body) do
      def character
        return if character_name.nil?
        CharacterService.all.find_by_name(character_name)
      end

      def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
        prepare(action: :move, body: { x:, y: })
      end

      def fight
        prepare(action: :fight, body: { name: character_name })
      end

      def characters
        prepare(action: :characters)
      end

      def maps
        prepare(action: :maps)
      end

      def handle
        perform_all
      end

      private

      def prepare(action:, body: {})
        self.action = action
        self.body = body
        request(body:)
        self
      end

      def api_key
        ENV['API_KEY']
      end

      def request(get_vars = nil)
        uris = URI.encode_www_form(**get_vars) if get_vars.present?
        url = URI("#{BASE_URL}/#{uri}?#{uris}")
        request = type.new(url)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = "Bearer #{api_key}"
        request.body = JSON.generate(body)
        request
      end

      def perform_all
        page = 1
        items = []
        loop do
          handled_response = perform(page:)
          break if handled_response.nil?
          page += 1
          pages = handled_response[:pages]
          items.concat(handled_response[:items]) if handled_response[:items].is_a?(Array)
          break unless pages.present? && page <= pages
        end
        items
      end

      def perform(page:)
        http = Net::HTTP.new(request.uri.host, request.uri.port)
        http.use_ssl = true
        puts "#{character_text}#{action} #{JSON.parse(request.body)} #{page_text(page)}"
        response = http.request(request({ page: }))
        handle_response(response_code: response.code.to_i, response_body: response.body)
      end

      def handle_response(response_code:, response_body:)
        case response_code
        when 200
          handle_success(response_body:)
        when RESPONSE_CODES[:no_move]
          puts "#{character_text}already on tile"
        when RESPONSE_CODES[:cooldown]
          puts "#{character_text}on cooldown"
          RESPONSE_CODES[:cooldown]
        else
          puts "Error: #{response_code}"
          raise response_body
        end
      end

      def character_text
        character_name ? "#{character_name}: " : ''
      end

      def page_text(page)
        page > 1 ? "page: #{page}" : ''
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
