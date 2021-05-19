# frozen_string_literal: true

require 'rake/testtask'

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./spec/test_load_all'
end

desc 'Rake all the Ruby'
task :style do
  `rubocop .`
end

namespace :run do
  # Run in development mode
  task :dev do
    sh 'rackup -p 9292'
  end
end
