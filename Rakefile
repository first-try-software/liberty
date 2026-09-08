# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

FLOG_LIMIT = 10.0

def qlty_bin
  installed = File.expand_path("~/.qlty/bin/qlty")
  ENV.fetch("QLTY_BIN") { File.exist?(installed) ? installed : "qlty" }
end

desc "Run qlty lint checks and report code smells"
task :qlty do
  sh qlty_bin, "check", "--all", "--no-progress"
  sh qlty_bin, "smells", "--all", "--quiet"
end

desc "Fail when the average flog score per method reaches #{FLOG_LIMIT}"
task :flog do
  report = `bundle exec flog -m lib`
  puts report
  average = report[/^\s*([\d.]+): flog\/method average/, 1].to_f
  abort("Quality gate failed: average flog #{average} is #{FLOG_LIMIT} or higher") if average >= FLOG_LIMIT
end

task default: %i[spec standard qlty flog]
