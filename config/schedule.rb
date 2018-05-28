# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :additionnal_path, ''
unless additionnal_path.empty?
  env :PATH, "#{additionnal_path}:#{ENV['PATH']}"
end
set :NEW_RELIC_LOG, 'stdout'

set :job_template, "/bin/bash -c ':job'"

every :hour do
  runner "Cron.every_hour"
end

every :day, :at => '3:00am' do
  runner "Cron.every_day_at_3AM"
end

every :day, :at => '4:00 am' do
 runner "Cron.every_day_at_4AM"
end

every 5.minutes do
  runner "Cron.every_5_minutes"
end

every 1.minute do
  command "/bin/echo HeartBeat"
end
