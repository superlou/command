require 'artemis'
require './components.rb'
require 'eventmachine'

class GameServer
	def run
		puts "Starting server..."
		@world = Artemis::World.new
		@world.add_manager Artemis::TagManager.new

		@world.set_system(RouteMovementSystem.new).setup
		@world.set_system(PlayerUpdateSystem.new).setup

		city = @world.create_entity(LocationComponent.new(0, 0))
		city.add_to_world

		force = @world.create_entity(LocationComponent.new(32, 10),
									 RouteComponent.new,
									 TopSpeedComponent.new)
		force.add_to_world


		@counter = 1
		client = Faye::Client.new('http://localhost:8080/faye')

		EM.run do
			client.subscribe('/public') do |msg|
				if msg['text'] == "new_client"
					player = @world.create_entity(PlayerComponent.new, FayeClientComponent.new(client))
					player.add_to_world
				end
			end

			EM.add_periodic_timer(1) do
				world_step
			end
		end
	end

	def world_step
		@world.delta = @counter
		@world.process
		@counter += 1
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

class PlayerUpdateSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all PlayerComponent, FayeClientComponent)
	end

	def setup
		@player_mapper = Artemis::ComponentMapper.new(PlayerComponent, @world)
		@faye_client_mapper = Artemis::ComponentMapper.new(FayeClientComponent, @world)
	end

	def process_entity(entity)
		unless @player_mapper.get(entity).received_welcome
			send_welcome_data(entity)
			@player_mapper.get(entity).received_welcome = true
		end
	end

	def send_welcome_data(entity)
		puts self.world.entity_manager
		@faye_client_mapper.get(entity).faye_client.publish '/public', text: 'welcome!'
	end
end
