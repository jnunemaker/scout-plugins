class RedisCounters < Scout::Plugin
  needs 'redis'

  OPTIONS = <<-EOS
  client_host:
    name: Host
    notes: "You will generally want this to be 'localhost'"
    default: localhost
  client_port:
    name: Port
    notes: Redis port to pass to the client library.
    default: 6379
  db:
    name: Database
    notes: Redis database ID to pass to the client library.
    default: 0
  password:
    name: Password
    notes: If you're using Redis' password authentication.
    attributes: password
  keys:
    name: Keys to monitor
    notes: A comma-separated list of incrementing keys to monitor value of.
  EOS

  def build_report
    redis = Redis.new :port     => option(:client_port),
                      :db       => option(:db),
                      :password => option(:password),
                      :host     => option(:client_host)

    if option(:keys)
      keys = option(:keys).split(',')
      keys.each do |key|
        begin
          value = redis.get(key).to_i
          puts value.inspect
          counter(key.to_sym, value, :per => :second)
        rescue Errno::ECONNREFUSED => error
          return error( "Could not connect to Redis.",
                        "Make certain you've specified correct port, DB and password." )
        end
      end
    end
  end
end