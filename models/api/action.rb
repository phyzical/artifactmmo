# frozen_string_literal: true

Dir[File.join(__dir__, '..', '*.rb')].each { |file| require file }

module API
  BASE_URL = 'https://api.artifactsmmo.com'

  CHARACTER_NAME_KEY = 'CHARACTER_NAME'
  ACTIONS = {
    move: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/move",
      type: Net::HTTP::Post,
      add_to_queue: true
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
    monsters: {
      uri: 'monsters',
      type: Net::HTTP::Get,
      model: Monster
    },
    items: {
      uri: 'items',
      type: Net::HTTP::Get,
      model: Item
    },
    fight: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/fight",
      type: Net::HTTP::Post,
      add_to_queue: true
    },
    rest: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/rest",
      type: Net::HTTP::Post,
      add_to_queue: true
    },
    deposit: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/bank/deposit",
      type: Net::HTTP::Post,
      add_to_queue: true
    },
    deposit_gold: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/bank/deposit/gold",
      type: Net::HTTP::Post,
      add_to_queue: true
    }
  }.freeze

  module Action
    def self.new(keys = {})
      Item.new(**keys, responses: [])
    end

    Item =
      Struct.new(:character_name, :action, :body, :responses) do
        def character
          return if character_name.nil?
          CharacterService.find_by_name(character_name)
        end

        def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
          prepare(action: :move, body: { x:, y: })
        end

        def fight
          prepare(action: :fight)
        end

        def rest
          prepare(action: :rest)
        end

        def deposit(code:, quantity:)
          if code == InventoryItem::CODES[:gold]
            deposit_gold(quantity:)
          else
            prepare(action: :deposit, body: { code:, quantity: })
          end
        end

        def monsters
          prepare(action: :monsters)
        end

        def items
          prepare(action: :items)
        end

        def characters
          prepare(action: :characters)
        end

        def maps
          prepare(action: :maps)
        end

        def handle
          loop do
            response = perform(page: (responses.last&.page || 0) + 1)
            responses << response
            break if response.data.nil? || response.code == Response::CODES[:character_in_cooldown]
            break unless response.pages.present? && response.page <= response.pages
          end
        end

        def data
          responses.map(&:data).flatten
        end

        def character_text
          character_name ? "#{character_name}: " : ''
        end

        def model
          ACTIONS[action][:model]
        end

        private

        def deposit_gold(quantity:)
          prepare(action: :deposit_gold, body: { quantity: })
        end

        def prepare(action:, body: {})
          self.action = action
          self.body = body
          API::QueueService.handle_action(action: self)
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

        def perform(page:)
          generated_request = request({ page: page })
          http = Net::HTTP.new(generated_request.uri.host, generated_request.uri.port)
          http.use_ssl = true
          puts "#{character_text}#{action} #{JSON.parse(generated_request.body)} #{page_text(page:)}"
          Response.new(action: self, response: http.request(generated_request))
        end

        def page_text(page:)
          page && page > 1 ? "page: #{page}" : ''
        end

        def uri
          ACTIONS[action][:uri].gsub(CHARACTER_NAME_KEY, character_name || '')
        end

        def type
          ACTIONS[action][:type]
        end
      end
  end
end
