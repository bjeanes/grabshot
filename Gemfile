source 'https://rubygems.org'

if ENV["RUBY_ENGINE"]
  engine, version = *ENV["RUBY_ENGINE"].split("-")
  ruby "1.9.3", :engine => engine, :engine_version => version
end

gem 'sinatra'
gem 'slim'
gem "puma", "~> 2.0.0.b6"

group :development do
  gem 'foreman'
end
