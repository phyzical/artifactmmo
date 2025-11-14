# frozen_string_literal: true

module AuthService
  class << self
    def init
      @init ||= api_key
    end

    def api_key
      @api_key ||= generate_api_key
    end

    def reset
      Logs.log(type: :puts, log: 'Resetting API key', info: true)
      @api_key = nil
    end

    def authorization_header
      { Authorization: "Basic #{Base64.strict_encode64("#{ENV['USERNAME']}:#{ENV['PASSWORD']}")}" }
    end

    private

    def generate_api_key
      API::Action.new.api_key.first
    end
  end
end
