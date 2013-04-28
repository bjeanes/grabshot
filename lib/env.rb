require 'rubygems'
require 'bundler'
Bundler.setup
require "dotenv" # this can set a default RACK_ENV

module Grabshot
  def self.environment
    (ENV["RACK_ENV"] ||= "development").to_sym
  end
end

Bundler.setup(:default, Grabshot.environment)

lib = File.dirname(__FILE__)
$:.unshift lib unless $:.include?(lib)
