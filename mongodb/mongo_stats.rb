class MongoStatsPlugin < Scout::Plugin
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

    stats = db.stats

    report(:objects      => stats['objects'])
    report(:data_size    => stats['dataSize'])
    report(:storage_size => stats['storageSize'])
    report(:indexes      => stats['indexes'])
    report(:index_size   => stats['indexSize'])
  end
end
