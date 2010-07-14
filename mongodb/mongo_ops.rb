class MongoOpsPlugin < Scout::Plugin
  OPTIONS=<<-EOS
    path_to_db_yml:
      label: Path to database.yml
      notes: For example: /path/to/myapp/current/config/database.yml
    rails_env:
      label: Rails Environment
      default: production
  EOS

  needs 'mongo', 'yaml'

  def build_report
    config     = YAML::load_file(option('path_to_db_yml'))[option('rails_env')]
    connection = Mongo::Connection.new(config['host'], config['port'])
    db         = connection.db(config['database'])
    db.authenticate(config['username'], config['password']) unless config['username'].nil?

    stats = db.command('serverStatus' => 1)

    op_inserts   = stats['opcounters']['insert']
    op_queries   = stats['opcounters']['query']
    op_updates   = stats['opcounters']['update']
    op_deletes   = stats['opcounters']['delete']
    op_get_mores = stats['opcounters']['getmore']
    op_commands  = stats['opcounters']['command']

    previous_inserts   = memory(:op_inserts)   || 0
    previous_queries   = memory(:op_queries)   || 0
    previous_updates   = memory(:op_updates)   || 0
    previous_deletes   = memory(:op_deletes)   || 0
    previous_get_mores = memory(:op_get_mores) || 0
    previous_commands  = memory(:op_commands)  || 0

    report(:inserts   => op_inserts   - previous_inserts)
    report(:queries   => op_queries   - previous_queries)
    report(:updates   => op_updates   - previous_updates)
    report(:deletes   => op_deletes   - previous_deletes)
    report(:get_mores => op_get_mores - previous_get_mores)
    report(:commands  => op_commands  - previous_commands)

    report(:total_inserts   => op_inserts)
    report(:total_queries   => op_queries)
    report(:total_updates   => op_updates)
    report(:total_deletes   => op_deletes)
    report(:total_get_mores => op_get_mores)
    report(:total_commands  => op_commands)

    remember(:op_inserts,   op_inserts)
    remember(:op_queries,   op_queries)
    remember(:op_updates,   op_updates)
    remember(:op_deletes,   op_deletes)
    remember(:op_get_mores, op_get_mores)
    remember(:op_commands,  op_commands)
  end
end
