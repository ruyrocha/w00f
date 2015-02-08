-- Another app stores IP addresses on Redis. The request will succeed if remote
-- address is present on Redis, or it will fail otherwise with an internal
-- server error.

local ip = ngx.var.remote_addr
local redis = require "resty.redis"
local redis_conn = redis:new()

-- set timeout to 1 second
redis_conn:set_timeout(1000)

local ok, err = redis_conn:connect("127.0.0.1", 6379)

if not ok then
  ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
  return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local ip_exists, err = redis_conn:get(ip)

if not ip_exists then
  ngx.log(ngx.ERR, "Failed to get IP from Redis: ", err)
  return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if ip_exists == ngx.null then
  ngx.log(ngx.ERR, "Unauthorized Access Attempt")
  return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
