begin
  uriRedis = ENV["REDISTOGO_URL"] ? ENV["REDISTOGO_URL"] : 'redis://127.0.0.1:6379'
  REDIS = Redis.new(:url => uriRedis)
rescue => e
  if Rails.env.development? || Rails.env.test?
    REDIS = nil
  else
    raise
  end
end