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