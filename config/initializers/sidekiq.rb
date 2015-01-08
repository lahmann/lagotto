Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new { |exception, hash| Alert.create(exception: exception) }
end

Sidekiq::Logging.logger.level = Logger::DEBUG
