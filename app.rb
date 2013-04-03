require 'rubygems'
require 'bundler'

Bundler.setup(:default)
require 'sinatra'
Bundler.setup(:default, settings.environment)

configure :development do
  require 'rack/reloader'
  Sinatra::Application.reset!
  use Rack::Reloader
end

get '*' do
  'Bye'
end
