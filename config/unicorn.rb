worker_processes 2
timeout 30
preload_app true

@jobs_pid = nil

before_fork do |server, worker|
  @jobs_pid ||= spawn("bundle exec sidekiq")
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Split) && !Split.redis.nil?
    Split.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  # # If you are using Redis but not Resque, change this
  if defined?(Split)
    require 'open-uri'
    uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379")
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    Split.redis = redis
    Rails.logger.info('Connected to Redis')
  end
end
