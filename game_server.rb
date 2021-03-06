require 'rubygems'
require 'bundler/setup'
require 'active_support/inflector'
require 'artemis'
require 'faye'
require 'eventmachine'
require 'yaml'

require './components.rb'

class GameServer
	def run
		puts "Starting server..."
		@world = Artemis::World.new
		@world.add_manager Artemis::GroupManager.new
		@world.add_manager Artemis::TagManager.new

		load_systems

		city_populations = YAML.load(File.read 'data/city_data.yml')
		city_populations.each do |cp|
			c = @world.create_entity(LocationComponent.new(cp['lat'], cp['lon']),
					 NameComponent.new(cp['name']),
					 PopulationComponent.new(cp['population']),
					 UuidComponent.new
					 )
			c.add_to_world
			@world.get_manager(Artemis::GroupManager).add(c, "cities")
			@world.get_manager(Artemis::TagManager).register(
				c.get_component(UuidComponent).uuid, c
			)
		end

		force = @world.create_entity(LocationComponent.new(39.96234, -75.26191),
									 TopSpeedComponent.new,
									 ForceMakeupComponent.new,
									 UuidComponent.new)
		force.add_to_world
		@world.get_manager(Artemis::GroupManager).add(force, "forces")
		@world.get_manager(Artemis::TagManager).register(
				force.get_component(UuidComponent).uuid, force
		)


		@counter = 1
		client = Faye::Client.new('http://localhost:8080/faye')

		EM.run do
			client.subscribe('/public') do |msg|
				if msg['type'] == "new_client_connection"
					player = @world.create_entity(PlayerComponent.new, FayeClientComponent.new(client))
					player.add_to_world
				elsif msg['type'] == "player_cmd"
					force = @world.get_manager(Artemis::TagManager).get_entity(msg['force_uuid'])
					force.add_component(MovementGoalComponent.new(msg['goal'][0], msg['goal'][1]))
					force.add_to_world
				end
			end

			EM.add_periodic_timer(1) do
				world_step
			end
		end
	end

	def world_step
		@world.delta = 60 # seconds
		@world.process
		@counter += 1
	end

	def load_systems
		Dir[File.dirname(__FILE__) + '/systems/*.rb'].each do |file|
			require file
			system_class = File.basename(file, '.rb').classify.constantize
			@world.set_system(system_class.new).setup
		end
	end
end

gs = GameServer.new

begin
	gs.run
rescue Interrupt => e
	puts "Shutting down game server."
end