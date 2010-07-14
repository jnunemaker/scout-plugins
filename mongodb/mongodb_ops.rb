class MongoDBOps < Scout::Plugin
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
    stats      = db.command('serverStatus' => 1)

    op_inserts   = stats['opcounters']['insert']
    op_queries   = stats['opcounters']['query']
    op_updates   = stats['opcounters']['update']
    op_deletes   = stats['opcounters']['delete']
    op_get_mores = stats['opcounters']['getmore']
    op_commands  = stats['opcounters']['command']

    original_inserts   = memory(:op_inserts) 	|| 0
    original_queries   = memory(:op_queries) 	|| 0
    original_updates   = memory(:op_updates) 	|| 0
    original_deletes   = memory(:op_deletes) 	|| 0
    original_get_mores = memory(:op_get_mores) 	|| 0
    original_commands  = memory(:op_commands) 	|| 0

    remember(:op_inserts,   op_inserts)
    remember(:op_queries,   op_queries)
    remember(:op_updates,   op_updates)
    remember(:op_deletes,   op_deletes)
    remember(:op_get_mores, op_get_mores)
    remember(:op_commands,  op_commands)

    report(:inserts   => op_inserts   - original_inserts)
    report(:queries   => op_queries   - original_queries)
    report(:updates   => op_updates   - original_updates)
    report(:deletes   => op_deletes   - original_deletes)
    report(:get_mores => op_get_mores - original_get_mores)
    report(:commands  => op_commands  - original_commands)
  end
end
