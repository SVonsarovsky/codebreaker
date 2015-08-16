require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.coverage_dir('data/coverage')
SimpleCov.start do
  add_filter 'spec/'
end

require 'codebreaker'
