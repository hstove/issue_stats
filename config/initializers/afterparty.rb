if (queue = Rails.configuration.queue).is_a?(Afterparty::Queue)
  queue.config_login do |username, password|
    # change this to something more secure!
    username == "admin" && password == "password"
  end
end