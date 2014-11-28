require 'rack-mini-profiler'

# initialization is skipped so trigger it
Rack::MiniProfilerRails.initialize!(Rails.application) if Rails.env == 'development'

Rack::MiniProfiler.config.storage       = Rack::MiniProfiler::MemcacheStore
Rack::MiniProfiler.config.base_url_path = "/api/mini-profiler-resources/"
Rack::MiniProfiler.config.auto_inject   = false
