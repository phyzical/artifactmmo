# frozen_string_literal: true

module API
  module Request
    def self.new(keys)
      Thing.new(**keys)
    end
    CACHE_DIR = 'cache'

    Thing =
      Struct.new(:action, :http_request) do
        delegate :save?, :cache?, to: :action

        def perform
          response = cached_response
          response ||= http.request(http_request)
          cache_response(response:) if (cache? && !cached_response?) || save?
          response
        end

        def uri
          http_request.uri.to_s
        end

        private

        def http
          https = Net::HTTP.new(http_request.uri.host, http_request.uri.port)
          https.use_ssl = true
          https
        end

        def page
          uri_get_vars[:page] || 1
        end

        def uri_get_vars
          http_request.uri.query.split('&').to_h { |pair| pair.split('=') }
        end

        def body
          JSON.parse(http_request.body)
        end

        def cache_file_name
          cache_key = uri_get_vars.reduce('') { |acc, (k, v)| "#{acc}-#{k}-#{v}" }
          cache_key += body.reduce('') { |acc, (k, v)| "#{acc}-#{k}-#{v}" }
          cache_key = cache_key.sub(/^-/, '')
          File.join(CACHE_DIR, "#{save? && 'save-'}#{action.action}-#{cache_key}.json")
        end

        def cached_response?
          File.exist?(cache_file_name)
        end

        def cached_response
          return if !cached_response? || save?
          Logs.log(type: :puts, log: 'Pulling from cache')
          CachedResponse.new(body: File.read(cache_file_name), code: Response::CODES[:success])
        end

        def cache_response(response:)
          FileUtils.mkdir_p(CACHE_DIR)
          File.write(cache_file_name, response.body)
        end
      end
  end
end
