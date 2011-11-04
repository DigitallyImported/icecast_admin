require "bundler/gem_tasks"

task :default => [:console]

desc "Open a test IRB console"
task :console do
  sh 'irb --simple-prompt -rubygems -I lib -r pp -r icecast_admin.rb'
end
