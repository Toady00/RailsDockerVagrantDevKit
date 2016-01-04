require 'socket'

DEFAULT_HOST = 'localhost'
DEFAULT_PORT = 5432
DEFAULT_RETRIES = 10
WAIT = 1

namespace :ci do
  desc 'Check if database server/port is accepting connections'
  task :wait_for_db, [:retries] => [:environment] do |t, args|
    args.with_defaults(retries: DEFAULT_RETRIES)
    success = args.retries.times do
      break true if port_open?
      sleep WAIT
      false
    end
    abort("Database not ready") unless success
  end
end

def port_open?
  host = ActiveRecord::Base.connection_config[:host] || DEFAULT_HOST
  port = ActiveRecord::Base.connection_config[:port] || DEFAULT_PORT
  TCPSocket.new(host, port).close
  true
rescue Errno::ECONNREFUSED
  false
end

