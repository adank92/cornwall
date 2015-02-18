set :output, error: 'log/cron_error.log', standard: 'log/cron.log'

every 6.hours do
  rake 'default'
end
