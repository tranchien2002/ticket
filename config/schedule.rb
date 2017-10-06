set :output, "log/cron_log.log"

every 15.minutes do
  rake "ticket:update_deadline"
end
