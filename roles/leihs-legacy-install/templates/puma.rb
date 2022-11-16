workers({{leihs_legacy_workers}})
threads(1,{{leihs_legacy_max_threads_per_worker}})
bind("tcp://localhost:{{LEIHS_LEGACY_HTTP_PORT}}")
environment("production")

{% if leihs_legacy_puma_worker_killer_enabled %}

before_fork do
  require 'puma_worker_killer'
  PumaWorkerKiller.enable_rolling_restart
  PumaWorkerKiller.config do |config|
    config.ram           = {{leihs_legacy_puma_worker_killer_ram}} # mb
    config.frequency     = 60    # seconds
    config.percent_usage = 0.98
    config.rolling_restart_frequency = 3 * 60 * 60
    config.reaper_status_logs = false

    config.pre_term = -> (worker) { puts "Worker #{worker.inspect} being killed" }
    config.rolling_pre_term = -> (worker) { puts "Worker #{worker.inspect} being killed by rolling restart" }
  end
  PumaWorkerKiller.start
end

{% else %}

# the puma worker killer is disabled,
# set leihs_legacy_puma_worker_killer_enabled to change this

{% endif %}


