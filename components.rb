require 'rubygems'
require 'bundler/setup'
require 'artemis'

class LocationComponent < Artemis::Component
	attr_accessor :lat, :lon

	def initialize(lat, lon)
		@lat = lat
		@lon = lon
	end
end

class RouteComponent < Artemis::Component
	attr_accessor :path, :arrival_time
end

class TopSpeedComponent < Artemis::Component
	attr_accessor :top_speed
end

class PlayerComponent < Artemis::Component
	attr_accessor :received_welcome

	def initialize
		@received_welcome = false
	end
end

class FayeClientComponent < Artemis::Component
	attr_accessor :faye_client

	def initialize(faye_client)
		@faye_client = faye_client
	end
end