require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

DOCKER_IMAGE_NAME = 'git_acl_shell'

namespace :docker do
  desc "build the image"
  task :build do
    sh "docker build -t #{DOCKER_IMAGE_NAME} #{Dir.pwd}"
  end

  desc "run tests in docker"
  task :spec do
    sh %{docker run --rm -v "#{Dir.pwd}":/src -it -w /src #{DOCKER_IMAGE_NAME} /bin/bash -c "bundle exec rspec"}
  end
end
