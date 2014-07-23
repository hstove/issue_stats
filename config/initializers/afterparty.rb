queue = Rails.configuration.queue = Afterparty::Queue.new

queue.config_login do |username, password|
  # change this to something more secure!
  username == "admin" && password == "password"
end