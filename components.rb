require 'rubygems'
require 'bundler/setup'
require 'artemis'
require 'securerandom'

class Component < Artemis::Component
	def serialize
		vars = {}
		instance_variables.each do |ivar| 
			vars[ivar.to_s[1..-1]] = instance_variable_get(ivar)
		end

		vars
	end

	def removed(entity)
	end
end

class UuidComponent < Component
	attr_accessor :uuid

	def initialize
		@uuid = SecureRandom.uuid
	end
end

class PopulationComponent < Component
	attr_accessor :population

	def initialize(population)
		@population = population
	end
end

class LocationComponent < Component
	attr_accessor :lat, :lon

	def initialize(lat, lon)
		@lat = lat
		@lon = lon
	end
end

class MovementGoalComponent < Component
	attr_accessor :lat, :lon, :arrival_time

	def initialize(lat, lon)
		@lat = lat
		@lon = lon
	end
end

class TopSpeedComponent < Component
	attr_accessor :top_speed # MPH

	def top_speed_meters_per_second
		top_speed * 0.44704
	end
end

class ForceMakeupComponent < Component
	attr_accessor :makeup
end

class PlayerComponent < Component
	attr_accessor :received_welcome

	def initialize
		@received_welcome = false
	end
end

class FayeClientComponent < Component
	attr_accessor :faye_client

	def initialize(faye_client)
		@faye_client = faye_client
	end
end

class NameComponent < Component
	attr_accessor :name

	def initialize(name)
		@name = name
	end
end
