class Redis::Configuration
  class << self
    def load_config(redis_yml = File.join(Rails.root, 'config', 'redis.yml'))
      config = YAML.load_file(redis_yml)
      default = config['default']
      @config = default.merge(config[Rails.env] || {}).symbolize_keys
    end

    def url
      "redis://#{host}:#{port}/#{db}"
    end
  end

  %i(host port db).each do |key|
    define_singleton_method(key) do
      @config[key]
    end
  end

  load_config
end
