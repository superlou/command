require 'artemis'
require './components.rb'
require 'eventmachine'
require 'yaml'

class GameServer
	def run
		puts "Starting server..."
		@world = Artemis::World.new
		@world.add_manager Artemis::GroupManager.new

		load_systems

		city_populations = YAML.load(File.read 'data/city_data.yml')
		city_populations.each do |cp|
			c = @world.create_entity(LocationComponent.new(cp['lat'], cp['lon']),
					 NameComponent.new(cp['name']),
					 PopulationComponent.new(cp['population'])
					 )
			c.add_to_world
			@world.get_manager(Artemis::GroupManager).add(c, "cities")
		end

		force = @world.create_entity(LocationComponent.new(39.96234, -75.26191),
									 RouteComponent.new,
									 TopSpeedComponent.new)
		force.add_to_world


		@counter = 1
		client = Faye::Client.new('http://localhost:8080/faye')

		EM.run do
			client.subscribe('/public') do |msg|
				if msg['type'] == "new_client_connection"
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

	def load_systems
		Dir[File.dirname(__FILE__) + '/systems/*.rb'].each do |file|
			require file
			system_class = File.basename(file, '.rb').classify.constantize
			@world.set_system(system_class.new).setup
		end
	end
end