# frozen_string_literal: true

Dir[File.join(__dir__, '..', '**', '*.rb')].each { |file| require file }

module API
  BASE_URL = 'https://api.artifactsmmo.com'

  URI_REPLACEMENT_KEYS = { CHARACTER_NAME: 'CHARACTER_NAME', CODE: 'CODE' }.freeze

  ACTIONS = {
    move: {
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/move",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:)
        [MapsService.find_by_position(**raw_data[:destination].slice(:x, :y))]
      end
    },
    generate_api_key: {
      uri: 'token',
      type: Net::HTTP::Post,
      data_handler: ->(raw_data) { raw_data[:token] },
      headers: -> { ::AuthService.authorization_header }
    },
    characters: {
      uri: 'my/characters',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Characters::Character.new(**x) } },
      save: true
    },
    new_character: {
      uri: 'characters/create',
      type: Net::HTTP::Post,
      data_handler: ->(raw_data) { [Characters::Character.new(**raw_data)] }
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
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/fight",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:)
        fight_data = raw_data[:fight]
        fight_data.delete(:characters).each { |char_data| CharacterService.update(**raw_data[:fight], **char_data) }
      end
    },
    gather: {
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/gathering",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:)
        [Skills::Details.new(**raw_data[:details])]
      end
    },
    rest: {
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/rest",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:).map { "Restored #{raw_data[:hp_restored]} (#{it.hp}/#{it.max_hp})" }
      end
    },
    deposit: {
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/bank/deposit/item",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:)
        BankService.update_items(bank_items: raw_data[:bank])
        raw_data[:items].map { |item_data| Item.new(**item_data) }
      end
    },
    deposit_gold: {
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/bank/deposit/gold",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:)
        [BankService.update_gold(**raw_data[:bank])]
      end
    },
    bank: {
      uri: 'my/bank',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { [Locations::Bank.new(**raw_data)] },
      save: true
    },
    bank_items: {
      uri: 'my/bank/items',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Characters::Item.new(**x) } },
      save: true
    },
    task: {
      uri: "my/#{URI_REPLACEMENT_KEYS[:CHARACTER_NAME]}/action/task/new",
      type: Net::HTTP::Post,
      add_to_queue: true,
      data_handler: ->(raw_data) do
        update_characters(raw_data:)
        [Task.new(**raw_data[:task])]
      end
    },
    tasks: {
      uri: 'tasks/list',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Task.new(**x) } },
      cache: true
    },
    achievements: {
      uri: 'achievements',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Achievement.new(**x) } },
      cache: true
    },
    resources: {
      uri: 'resources',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Characters::Resource.new(**x) } },
      cache: true
    },
    badges: {
      uri: 'badges',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Badges::Badge.new(**x) } },
      cache: true
    },
    npcs: {
      uri: 'npcs/details',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Npcs::Npc.new(**x) } },
      cache: true
    },
    npc_items: {
      uri: "npcs/items/#{URI_REPLACEMENT_KEYS[:CODE]}",
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Npcs::Item.new(**x) } },
      cache: true
    },
    effects: {
      uri: 'effects',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Effect.new(**x) } },
      cache: true
    },
    events: {
      uri: 'events',
      type: Net::HTTP::Get,
      data_handler: ->(raw_data) { raw_data.map { |x| Event.new(**x) } },
      cache: true
    }
  }.freeze

  def self.update_characters(raw_data:)
    return [] if raw_data[:character].nil? && raw_data[:characters].nil?
    (raw_data[:characters] || [raw_data[:character]]).map { |char_data| CharacterService.update(char_data) }
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

        def api_key
          prepare(action: :generate_api_key)
        end

        def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
          prepare(action: :move, body: { x:, y: })
        end

        def fight
          prepare(action: :fight)
        end

        def gather
          prepare(action: :gather)
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
          if code == ::Item.code(code: :gold)
            deposit_gold(quantity:)
          else
            prepare(action: :deposit, body: [{ code:, quantity: }])
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

        def new_character(name:, skin:)
          prepare(action: :new_character, body: { name:, skin: })
        end

        def maps
          prepare(action: :maps)
        end

        def achievements
          prepare(action: :achievements)
        end

        def badges
          prepare(action: :badges)
        end

        def resources
          prepare(action: :resources)
        end

        def events
          prepare(action: :events)
        end

        def effects
          prepare(action: :effects)
        end

        def npcs
          prepare(action: :npcs)
        end

        def npc_items(code:)
          prepare(action: :npc_items, body: { code: })
        end

        def task
          prepare(action: :task, body: { name: character_name })
        end

        def handle
          loop do
            response = perform(page: (responses.last&.page || 0) + 1)
            break if response.data.nil? || response.code == Response::CODES[:character_in_cooldown]
            break unless response.pages.present? && response.page < response.pages
          end
        end

        def data
          responses.map(&:data).flatten
        end

        def data_handler(raw_data:)
          ACTIONS[action][:data_handler]&.call(raw_data) || raw_data
        end

        def extra_headers
          ACTIONS[action][:headers]&.call || {}
        end

        def add_to_queue?
          ACTIONS[action][:add_to_queue] || false
        end

        def add_response(response:)
          responses.push(response)
        end

        def move_redundant?
          action == :move && character.position == body
        end

        def character_log
          character_name ? " #{character_name}:" : ''
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

        def perform(page:)
          Response.new(action: self, request: Request.new(action: self, get_vars: { page: }))
        end
      end
  end
end
