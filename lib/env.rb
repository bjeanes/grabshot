require 'rubygems'
require 'bundler'
Bundler.setup

# Allow .env file to set RACK_ENV
require "dotenv"
Dotenv.load

module Grabshot
  def self.environment
    (ENV["RACK_ENV"] ||= "development").to_sym
  end
end

Bundler.setup(:default, Grabshot.environment)

lib = File.dirname(__FILE__)
$:.unshift lib unless $:.include?(lib)
