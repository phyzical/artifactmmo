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
      uri: "my/#{CHARACTER_NAME_KEY}/action/fight",
      type: Net::HTTP::Post
    },
    rest: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/rest",
      type: Net::HTTP::Post
    },
    deposit: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/bank/deposit",
      type: Net::HTTP::Post
    },
    deposit_gold: {
      uri: "my/#{CHARACTER_NAME_KEY}/action/bank/deposit/gold",
      type: Net::HTTP::Post
    }
  }.freeze

  RESPONSE_CODES = {
    # General
    invalid_payload: 422,
    too_many_requests: 429,
    not_found: 404,
    fatal_error: 500,
    # Account Error Codes
    token_invalid: 452,
    token_expired: 453,
    token_missing: 454,
    token_generation_fail: 455,
    username_already_used: 456,
    email_already_used: 457,
    same_password: 458,
    current_password_invalid: 459,
    # Character Error Codes
    character_not_enough_hp: 483,
    character_maximum_utilites_equiped: 484,
    character_item_already_equiped: 485,
    character_locked: 486,
    character_not_this_task: 474,
    character_too_many_items_task: 475,
    character_no_task: 487,
    character_task_not_completed: 488,
    character_already_task: 489,
    character_already_map: 490,
    character_slot_equipment_error: 491,
    character_gold_insufficient: 492,
    character_not_skill_level_required: 493,
    character_name_already_used: 494,
    max_characters_reached: 495,
    character_not_level_required: 496,
    character_inventory_full: 497,
    character_not_found: 498,
    character_in_cooldown: 499,
    # Item Error Codes
    item_insufficient_quantity: 471,
    item_invalid_equipment: 472,
    item_recycling_invalid_item: 473,
    item_invalid_consumable: 476,
    missing_item: 478,
    # Grand Exchange Error Codes
    ge_max_quantity: 479,
    ge_not_in_stock: 480,
    ge_not_the_price: 482,
    ge_transaction_in_progress: 436,
    ge_no_orders: 431,
    ge_max_orders: 433,
    ge_too_many_items: 434,
    ge_same_account: 435,
    ge_invalid_item: 437,
    ge_not_your_order: 438,
    # Bank Error Codes
    bank_insufficient_gold: 460,
    bank_transaction_in_progress: 461,
    bank_full: 462,
    # Maps Error Codes
    map_not_found: 597,
    map_content_not_found: 598
  }.freeze

  CONTINUE_RESPONSE_CODES = [
    RESPONSE_CODES[:character_inventory_full],
    RESPONSE_CODES[:character_already_map],
    RESPONSE_CODES[:character_in_cooldown]
  ].freeze

  Action =
    Struct.new(:character_name, :action, :body) do
      def character
        return if character_name.nil?
        CharacterService.find_by_name(character_name)
      end

      def move(x: 0, y: 0) # rubocop:disable Naming/MethodParameterName
        add_to_queue(action: :move, body: { x:, y: })
      end

      def fight
        add_to_queue(action: :fight)
      end

      def rest
        add_to_queue(action: :rest)
      end

      def deposit(code:, quantity:)
        if code == InventoryItem::CODES[:gold]
          deposit_gold(quantity:)
        else
          add_to_queue(action: :deposit, body: { code:, quantity: })
        end
      end

      def characters
        prepare(action: :characters).handle
      end

      def maps
        prepare(action: :maps).handle
      end

      def handle
        perform_all
      end

      private

      def deposit_gold(quantity:)
        prepare(action: :deposit_gold, body: { quantity: })
      end

      def prepare(action:, body: {})
        self.action = action
        self.body = body
        request(body:)
        self
      end

      def add_to_queue(action:, body: {})
        API::QueueService.add(prepare(action:, body:))
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
          break if handled_response.nil? || handled_response.instance_of?(Integer)
          page += 1
          pages = handled_response[:pages]
          items.concat(handled_response[:items])
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
        else
          response_code_text = RESPONSE_CODES.key(response_code)
          response_code_raise = CONTINUE_RESPONSE_CODES.exclude?(response_code)
          if response_code_raise
            puts "Error: #{response_code} -> #{response_code_text}"
            raise response_body
          else
            puts "#{character_text}#{response_code_text}"
            response_code
          end
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
        response = { items: [], **payloads.slice(:page, :pages) }
        if model.present? && items.is_a?(Array)
          response[:items] = items.map { |payload| model.new(**payload) }
        elsif model.present?
          response[:items] = [model.new(**items)]
        else
          CharacterService.update(items[:character])
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
