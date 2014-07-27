# Octokit.auto_paginate = true
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

    def skinny url, opts={}, &block
      opts[:per_page] ||= 100
      data = client.get(url, opts)
      block.call(data)
      @last_response = client.last_response
      while @last_response.rels[:next]
        @last_response = last_response.rels[:next].get
        block.call(@last_response.data)
      end
    end
  end
end