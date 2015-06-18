Sidekiq.configure_server do |config|
  config.redis = { url: Redis::Configuration.url }
end
