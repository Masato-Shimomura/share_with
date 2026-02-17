# threads
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# worker timeout
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# environment & port
environment ENV.fetch("RAILS_ENV") { "development" }
port ENV.fetch("PORT") { 3000 }

# tmp paths
rails_root = File.expand_path("../..", __FILE__)
pidfile File.join(rails_root, 'tmp/pids/puma.pid')
state_path File.join(rails_root, 'tmp/pids/puma.state')

stdout_redirect(
  File.join(rails_root, 'log/puma.log'),
  File.join(rails_root, 'log/puma-error.log'),
  true
)

# unixソケット
bind "unix://#{rails_root}/tmp/sockets/puma.sock"

# デーモン化（本番環境のみ）
daemonize true if ENV.fetch("RAILS_ENV") == "production"

# allow tmp restart
plugin :tmp_restart
