require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |task|
    task.rspec_opts = %w(--color --format documentation)
  end

  task :default => :spec
rescue LoadError
end