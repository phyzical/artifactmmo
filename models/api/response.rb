# frozen_string_literal: true

module API
  module Response
    CODES = {
      # General
      success: 200,
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

    CONTINUE_CODES = [
      CODES[:character_inventory_full],
      CODES[:character_already_map],
      CODES[:character_in_cooldown]
    ].freeze

    def self.new(action:, request:)
      response = Item.new(response: request.perform, action:, data: [])
      action.add_response(response:)
      response.handle
      response
    end

    Item =
      Struct.new(:response, :action, :data, :response_payload) do
        delegate :model, to: :action

        def handle
          self.response_payload = JSON.parse(response.body, symbolize_names: true)
          case code
          when 200
            success
          else
            if code_raise?
              Logs.log(type: :puts, log: "Error: #{code} -> #{code_log}", error: true)
              raise StandardError, response_payload[:message]
            else
              Logs.log(type: :puts, log: "#{action.character_log}#{code_log}", info: true)
            end
          end
        end

        def success
          self.data = action.data_handler(raw_data:)
        end

        def page
          response_payload[:page]
        end

        def pages
          response_payload[:pages]
        end

        def code
          response.code.to_i
        end

        private

        def code_log
          CODES.key(code)
        end

        def code_raise?
          CONTINUE_CODES.exclude?(code)
        end

        def body
          response.body
        end

        def raw_data
          response_payload[:data]
        end
      end
  end
end
