require 'rspec/core'
require 'rspec/core/rake_task'

require 'jettywrapper'

import 'lib/tasks/jetty.rake'

MARMOTTA_HOME = ENV['MARMOTTA_HOME'] ||
  File.expand_path(File.join(Jettywrapper.app_root, 'marmotta'))

Jettywrapper.url =
  'https://github.com/dpla/marmotta-jetty/archive/3.3.0-solr-4.9.0.zip'

desc "Run all specs in spec directory"
task :ci => ['jetty:clean'] do
  Jettywrapper.wrap(quiet: true, jetty_port: 8983, :startup_wait => 30) do
    Rake::Task["spec"].invoke
  end
end

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)
task :default => :ci
