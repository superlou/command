require 'artemis'
require './components.rb'
require 'eventmachine'

class GameServer
	def run
		puts "Starting server..."
		@world = Artemis::World.new
		@world.add_manager Artemis::GroupManager.new

		@world.set_system(RouteMovementSystem.new).setup
		@world.set_system(PlayerUpdateSystem.new).setup
		@world.set_system(FindCitiesSystem.new).setup
		@world.set_system(GrowCitiesSystem.new).setup

		c = @world.create_entity(LocationComponent.new(39.95234, -75.16191),
							 NameComponent.new('Philadelphia'),
							 PopulationComponent.new(1000)).add_to_world
		@world.get_manager(Artemis::GroupManager).add(c, "cities")

		c = @world.create_entity(LocationComponent.new(39.80147, -74.96761),
							 NameComponent.new('Camden'),
							 PopulationComponent.new(1000)).add_to_world
		@world.get_manager(Artemis::GroupManager).add(c, "cities")

		force = @world.create_entity(LocationComponent.new(32, 10),
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

		send_city_data(entity)
	end

	def send_welcome_data(entity)

	end

	def send_city_data(entity)
		data = self.world.get_system(FindCitiesSystem).all_cities.map { |e|
			serialize(e, NameComponent, LocationComponent, PopulationComponent)
		}

		@faye_client_mapper.get(entity).faye_client.publish '/public', {type: 'update_cities', data: data}
	end

	def serialize(entity, *component_classes)
		data = {}
		component_classes.each do |component_class|
			data[component_class.to_s] = entity.get_component(component_class).serialize
		end

		data
	end
end

class GrowCitiesSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all LocationComponent, NameComponent, PopulationComponent)
	end

	def setup
		@population_mapper = Artemis::ComponentMapper.new(PopulationComponent, @world)
	end

	def process_entity(entity)
		current_population = @population_mapper.get(entity).population
		new_population = current_population * 1.001
		@population_mapper.get(entity).population = new_population
	end
end


class FindCitiesSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all LocationComponent, NameComponent, PopulationComponent)
	end

	def setup
	end

	def process_entity(entity)
	end

	def all_cities
		@active_entities
	end
end