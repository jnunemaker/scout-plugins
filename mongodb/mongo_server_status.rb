class MongoServerStatusPlugin < Scout::Plugin
  OPTIONS=<<-EOS
    path_to_db_yml:
      label: Path to database.yml
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

    report(:btree_accesses                => stats['indexCounters']['btree']['accesses'])
    report(:btree_hits                    => stats['indexCounters']['btree']['hits'])
    report(:btree_misses                  => stats['indexCounters']['btree']['misses'])
    report(:btree_resets                  => stats['indexCounters']['btree']['resets'])
    report(:btree_miss_ratio              => stats['indexCounters']['btree']['missRatio'])
    report(:global_lock_total_time        => stats['globalLock']['totalTime'])
    report(:global_lock_lock_time         => stats['globalLock']['lockTime'])
    report(:global_lock_ratio             => stats['globalLock']['ratio'])
    report(:background_flushes_total      => stats['backgroundFlushing']['flushes'])
    report(:background_flushes_total_ms   => stats['backgroundFlushing']['total_ms'])
    report(:background_flushes_average_ms => stats['backgroundFlushing']['average_ms'])
    report(:background_flushes_last_ms    => stats['backgroundFlushing']['last_ms'])

    report(:mem_bits     => stats['mem']['bits'])      if stats['mem'] && stats['mem']['bits']
    report(:mem_resident => stats['mem']['resident'])  if stats['mem'] && stats['mem']['resident']
    report(:mem_virtual  => stats['mem']['virtual'])   if stats['mem'] && stats['mem']['virtual']
    report(:mem_mapped   => stats['mem']['mapped'])    if stats['mem'] && stats['mem']['mapped']
  end
end
