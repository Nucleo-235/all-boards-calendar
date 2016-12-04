require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["admin", "kike1234"]
end

Sidekiq.configure_client do |config|
    config.redis = { url: ENV["REDISTOGO_URL"], size: 1 }
end

Sidekiq.configure_server do |config|
    config.redis = { url: ENV["REDISTOGO_URL"], size: 5 }
end
