require_relative 'notifier'

desc 'generate a new message from bot'
task :new_message do
  notifier = Notifier.new
  notifier.parse_rss_feed
end
