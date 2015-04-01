require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Prwatch
  class Application < Rails::Application
    config.autoload_paths << "#{config.root}/lib"
    config.queue_adapter = :sidekiq

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec
    end

    require 'open-uri'
    uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379")
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

    config.redis = redis
    Split.redis = redis

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
