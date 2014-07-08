require Rails.root + 'domain/domain'

Fountain.configure do |config|
  config.logger = Logger.new($stdout)
  config.logger.level = Logger::INFO
end
