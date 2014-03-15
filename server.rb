require 'rubygems'
require 'bundler/setup'

require 'rack'
require './game_server.rb'

web_server_pid = fork do
	client_app = Rack::Builder.new do
	  run Rack::Directory.new(File.join(Dir.pwd(),'client'))
	end

	Rack::Handler::Thin.run(client_app, :port => 8080)
	exit
end

gs = GameServer.new

begin
	gs.run
rescue Interrupt => e
	puts "Shutting down game server."
end