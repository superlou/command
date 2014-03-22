require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'faye'

client_dir = File.join(Dir.pwd(),'client')

client_app = Rack::Builder.new do
  use Rack::CommonLogger

  use Rack::Static, urls: {"/client" => 'index.html'}, root: client_dir
  map "/client" do
  	run Rack::Directory.new(client_dir)
	  end

	  Faye::WebSocket.load_adapter('thin')
  run Faye::RackAdapter.new(mount: '/faye', timeout: 25)
end

Rack::Handler::Thin.run(client_app, :port => 8080)