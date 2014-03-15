require 'rubygems'
require 'bundler/setup'

require './game_server.rb'

gs = GameServer.new
gs.run