# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if Rails.env.development?
  namespace :db do
    desc "Force server restart after db:reset to refresh SQLite connections."
    task reset: :environment do
      # db:resetが完了した後、このブロックが実行されます
      Rake::Task["db:reset"].enhance do
        # サーバーの再起動を指示
        sh "touch tmp/restart.txt"
        puts "✅ tmp/restart.txt updated to force server connection refresh."
      end
    end
  end
end
