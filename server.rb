require 'rubygems'
require 'bundler/setup'

require 'rack'
require 'faye'
require './game_server.rb'

rack_pid = fork do
	client_dir = File.join(Dir.pwd(),'client')

	client_app = Rack::Builder.new do
	  use Rack::CommonLogger

	  use Rack::Static, urls: {"/client" => 'index.html'}, root: client_dir
	  map "/client" do
	  	run Rack::Directory.new(client_dir)
  	  end

	  run Faye::RackAdapter.new(mount: '/faye', timeout: 25)
	end

	Rack::Handler::Thin.run(client_app, :port => 8080)
	exit
end

# faye_server_pid = fork do
# 	bayeux = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
# 	run bayeux
# end

gs = GameServer.new

begin
	gs.run
rescue Interrupt => e
	puts "Shutting down game server."
end