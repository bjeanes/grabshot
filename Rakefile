require File.expand_path("../lib/env", __FILE__)

require "queue_classic"
require "queue_classic/tasks"

STDOUT.sync = true
STDERR.sync = true

# For worker...
autoload :Screenshotter, "screenshotter"

desc "Like qc:work except forks COUNT (default 3) workers"
task :multi_work, [:COUNT] do |_, args|
  count = (args[:COUNT] || 2).to_i
  count.times do
    fork do
      Rake::Task["qc:work"].invoke
    end
  end

  trap('INT')  { sleep 0.1; exit }
  trap('TERM') { puts "Terminating..." }

  Process.waitall
end

task :environment