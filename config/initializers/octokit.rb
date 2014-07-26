Octokit.auto_paginate = true
module GH
  class << self
    def method_missing method, *args
      key = *args
      Rails.cache.fetch(key, expires_at: 1.hour.from_now) do
        client.send method, *args
      end
    end
    def client
      @client ||= Octokit::Client.new access_token: ENV['PRWATCH_GITHUB_KEY']
    end
  end
end