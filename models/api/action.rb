# frozen_string_literal: true

Dir[File.join(__dir__, '..', '**', '*.rb')].each { |file| require file }

module API
  BASE_URL = 'https://api.artifactsmmo.com'

  CHARACTER_NAME_KEY = 'CHARACTER_NAME'
  ACTIONS = {
    move: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/move",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_character(raw_data:)
        [MapService.find_by_position(**raw_data[:destination].slice(:x, :y))]
      end
    },
    characters: {
      uri: 'my/characters',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Characters::Character.new(**x) } }
    },
    maps: {
      uri: 'maps',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Locations::Map.new(**x) } },
      cache: true
    },
    monsters: {
      uri: 'monsters',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Monsters::Monster.new(**x) } },
      cache: true
    },
    items: {
      uri: 'items',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Item.new(**x) } },
      cache: true
    },
    fight: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/fight",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_character(raw_data:)
        [Monsters::Fight.new(**raw_data[:fight])]
      end
    },
    rest: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/rest",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        character = update_character(raw_data:)
        ["Restored #{raw_data[:hp_restored]} (#{character.hp}/#{character.max_hp})"]
      end
    },
    deposit: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/bank/deposit",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_character(raw_data:)
        BankService.update_items(bank_items: raw_data[:bank])
        [Item.new(**raw_data[:item])]
      end
    },
    deposit_gold: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/bank/deposit/gold",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_character(raw_data:)
        [BankService.update_gold(**raw_data[:bank])]
      end
    },
    bank: {
      uri: 'my/bank',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { [Locations::Bank.new(**raw_data)] }
    },
    bank_items: {
      uri: 'my/bank/items',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Characters::Item.new(**x) } }
    },
    task: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/task/new",
      type: Net::HTTP::Post,
      data_handler: ->(raw_data) { [Tasks::Task.new(**raw_data)] }
    },
    tasks: {
      uri: 'tasks/list',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Tasks::Task.new(**x) } },
      cache: true
    }
  }.freeze

  def self.update_character(raw_data:)
    CharacterService.update(raw_data[:character])
  end

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

        def bank
          prepare(action: :bank)
        end

        def bank_items
          prepare(action: :bank_items)
        end

        def deposit(code:, quantity:)
          if code == Characters::Item.code(code: :gold)
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

        def tasks
          prepare(action: :tasks)
        end

        def characters
          prepare(action: :characters)
        end

        def maps
          prepare(action: :maps)
        end

        def task
          prepare(action: :task, body: { name: character_name })
        end

        def handle
          loop do
            response = perform(page: (responses.last&.page || 0) + 1)
            break if response.data.nil? || response.code == Response::CODES[:character_in_cooldown]
            break unless response.pages.present? && response.page <= response.pages
          end
        end

        def data
          responses.map(&:data).flatten
        end

        def character_log
          character_name ? "#{character_name}: " : ''
        end

        def data_handler(raw_data:)
          ACTIONS[action][:data_handler].call(raw_data)
        end

        def add_response(response:)
          responses.push(response)
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
          generated_request = request({ page: })
          http = Net::HTTP.new(generated_request.uri.host, generated_request.uri.port)
          http.use_ssl = true
          Logs.log(
            type: :puts,
            log: "#{character_log}#{action} #{body_log(body: generated_request.body)}#{page_log(page:)}",
            start: page.nil? || page == 1
          )
          Response.new(action: self, response: response(http:, generated_request:, page:))
        end

        def response(http:, generated_request:, page:)
          cache_dir = 'cache'
          file = File.join(cache_dir, "#{action}-#{page}.json")
          cache_response = CachedResponse.new(body: File.read(file), code: Response::CODES[:success]) if File.exist?(
            file
          )
          response = cache_response || http.request(generated_request)
          if cache? && cache_response.nil?
            (Dir.exist?(cache_dir) || Dir.mkdir(cache_dir)) && File.write(file, response.body)
          end
          response
        end

        def page_log(page:)
          page && page > 1 ? "page: #{page}" : ''
        end

        def body_log(body:)
          body == '{}' ? '' : "#{body} "
        end

        def uri
          ACTIONS[action][:uri].gsub(CHARACTER_NAME_KEY, character_name || '')
        end

        def type
          ACTIONS[action][:type]
        end

        def cache?
          ACTIONS[action][:cache]
        end
      end
  end
end
