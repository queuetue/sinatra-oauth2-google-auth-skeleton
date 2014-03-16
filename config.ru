#!/usr/bin/env rackup
# encoding: utf-8

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'data_mapper'
require './app.rb'

DataMapper.setup(:default, ENV['DATABASE_URL'])
DataMapper.finalize
DataMapper.auto_migrate!

run Rack::URLMap.new({
  "/"    => GSampleServer
})