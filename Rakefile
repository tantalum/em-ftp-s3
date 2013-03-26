require "bundler/gem_tasks"
Bundler.setup

require "rake"
require "rdoc/task"
require "rspec/core/rake_task"

# Run the test as the default task
desc "Default task"
task :default => [:spec]

# Run the rspec tests
desc "Run all rspec files"
RSpec::Core::RakeTask.new("spec") do |t|
	t.rspec_opts = ["--color", "--format progress"]
	#t.ruby_opts = "-w"
end

# Generate the RDoc documentation
desc "Generate docmentation"
RDoc::Task.new do |rdoc|
	rdoc.title = "em-ftpd-s3"
	rdoc.rdoc_dir = (ENV['CC_BUILD_ARTIFACTS'] || 'doc') + '/rdoc'
	rdoc.rdoc_files.include('README.md')
	rdoc.rdoc_files.include('CHANGELOG')
	rdoc.rdoc_files.include('LICENSE')
	rdoc.rdoc_files.include('lib/**/*.rb')
	rdoc.options << "--inline-source"
end
