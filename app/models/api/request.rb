# frozen_string_literal: true

module API
  module Request
    def self.new(keys)
      Thing.new(**keys)
    end
    CACHE_DIR = 'cache'

    Thing =
      Struct.new(:action, :get_vars) do
        delegate :body, :character_log, :character_name, to: :action

        def perform
          Logs.log(
            type: :puts,
            log:
              "#{character_log} #{action_name}#{body_log} (#{request_uri}) " \
                "#{cached_response? ? 'cached' : 'requesting'}",
            start: page == 1
          )
          response = cached_response || perform_request
          cache_response(response:) if (cache? && !cached_response?) || save?
          response
        end

        def request_uri
          http_request.uri.to_s
        end

        private

        def perform_request
          attempts = 0
          response = nil
          while response.nil?
            begin
              response = http.request(http_request)
            rescue Net::ReadTimeout => e
              Logs.log(type: :puts, log: 'Timeout, retrying', error: true)
              sleep(15)
            rescue Net::HTTPServerError => e
              Logs.log(type: :puts, log: 'Server, retrying', error: true)
              sleep(15)
            end

            if response&.code&.to_i == Response::CODES[:server_error]
              response = nil
              Logs.log(type: :puts, log: 'Server, retrying', error: true)
              sleep(15)
            end

            if attempts > 10
              Logs.log(type: :puts, log: "Too many attempts (#{attempts})", error: true)
              raise e
            end
            attempts += 1
          end
          response
        end

        def action_name
          action.action
        end

        def cache?
          @cache ||= ACTIONS[action_name][:cache]
        end

        def save?
          @save ||= ACTIONS[action_name][:save]
        end

        def type
          @type ||= ACTIONS[action_name][:type]
        end

        def uri
          uri = ACTIONS[action_name][:uri]
          if uri.include?(URI_REPLACEMENT_KEYS[:CHARACTER_NAME])
            uri = uri.gsub(URI_REPLACEMENT_KEYS[:CHARACTER_NAME], character_name)
          end
          uri = uri.gsub(URI_REPLACEMENT_KEYS[:CODE], body[:code]) if uri.include?(URI_REPLACEMENT_KEYS[:CODE])
          uri
        end

        def api_key
          ENV['API_KEY']
        end

        def body_log
          body == {} ? '' : " #{body}"
        end

        def http_request
          return @request if @request
          uris = URI.encode_www_form(**get_vars) if get_vars.present?
          url = URI("#{BASE_URL}/#{uri}?#{uris}")
          @request = type.new(url)
          @request['Content-Type'] = 'application/json'
          @request['Accept'] = 'application/json'
          @request['Authorization'] = "Bearer #{api_key}"
          @request.body = JSON.generate(body)
          @request
        end

        def http
          https = Net::HTTP.new(http_request.uri.host, http_request.uri.port)
          https.use_ssl = true
          https
        end

        def page
          num = uri_get_vars[:page].to_i
          num.positive? ? num : 1
        end

        def uri_get_vars
          http_request.uri.query.split('&').to_h { |pair| pair.split('=') }.symbolize_keys
        end

        def body
          action.body
        end

        def cache_file_name
          cache_key = uri_get_vars.reduce('') { |acc, (k, v)| "#{acc}-#{k}-#{v}" }
          cache_key += body.reduce('') { |acc, (k, v)| "#{acc}-#{k}-#{v}" }
          cache_key = cache_key.sub(/^-/, '')
          File.join(CACHE_DIR, "#{save? && 'save-'}#{action_name}-#{cache_key}.json")
        end

        def cached_response?
          File.exist?(cache_file_name)
        end

        def cached_response
          return if !cached_response? || save?
          CachedResponse.new(body: File.read(cache_file_name), code: Response::CODES[:success])
        end

        def cache_response(response:)
          FileUtils.mkdir_p(CACHE_DIR)
          File.write(cache_file_name, response.body)
        end
      end
  end
end
