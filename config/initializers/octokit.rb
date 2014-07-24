Octokit.auto_paginate = true
module GH
  class << self
    def client
      @client ||= Octokit::Client.new access_token: ENV['PRWATCH_GITHUB_KEY']
    end
  end
end