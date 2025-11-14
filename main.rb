# frozen_string_literal: true

Dir[File.join(__dir__, 'app', '**', '**', '*.rb')].each { |file| require file }

def run
  API::Request.clear_cache
  init_services
  ConstGenerator.generate_all
  API::QueueService.start
end

def init_services
  AuthService.init
  Dir[File.join(__dir__, 'app', 'services', '*.rb')].each do |file|
    next if file.include?('auth_service.rb')
    service_class = file.split('/').last.gsub('.rb', '').snake_to_camel
    Object.const_get(service_class).init
  end
end

begin
  run
rescue StandardError => e
  Logs.log(type: :pp, log: API::QueueService.responses.last, error: true)
  Logs.log(type: :pp, log: e.backtrace.map { |x| x.gsub('/app', '') }, error: true)
  raise e
end

#  TODOS
#  - make some loose algo to workout next best type to action when we call a skill
#  - add multi threading for queue so that all characters can run at the same time might not be worth the
#  complexity to save like ~3 seconds tops
