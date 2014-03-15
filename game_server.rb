require 'artemis'
require './components.rb'

class GameServer
	def run
		puts "Starting server..."
		@world = Artemis::World.new
		@world.add_manager Artemis::TagManager.new

		@world.set_system(RouteMovementSystem.new).setup

		city = @world.create_entity(LocationComponent.new(0, 0))
		city.add_to_world

		force = @world.create_entity(LocationComponent.new(32, 10),
									 RouteComponent.new,
									 TopSpeedComponent.new)
		force.add_to_world

		client_handler = @world.create_entity
		client_handler.add_to_world

		game_loop
	end

	def game_loop
		now = Time.now
		counter = 1
		loop do
			if Time.now < now + counter
				next
			else
				@world.delta = counter
				@world.process
			end

			counter += 1
		end
	end
end

class RouteMovementSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all TopSpeedComponent, RouteComponent, LocationComponent)
	end

	def setup
		@location_mapper = Artemis::ComponentMapper.new(LocationComponent, @world)
	end

	def process_entity(entity)
		#puts "process #{entity}"
	end
end