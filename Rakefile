task default: %w[test]

task :test do
  begin
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec)
    Rake::Task["spec"].execute
  rescue LoadError
  end
end
