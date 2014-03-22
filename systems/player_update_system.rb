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
		send_force_data(entity)
	end

	def send_welcome_data(entity)

	end

	def send_city_data(entity)
		data = self.world.get_system(FindCitiesSystem).all_cities.map { |e|
			serialize(e, NameComponent, LocationComponent, PopulationComponent, UuidComponent)
		}

		@faye_client_mapper.get(entity).faye_client.publish '/public', {type: 'update_cities', data: data}
	end

	def send_force_data(entity)
		force_entities = @world.get_manager(Artemis::GroupManager).get_entities('forces')
		data = force_entities.map do |force|
			serialize(force, LocationComponent, UuidComponent)
		end

		@faye_client_mapper.get(entity).faye_client.publish '/public', {type: 'update_forces', data: data}
	end

	def serialize(entity, *component_classes)
		data = {}
		component_classes.each do |component_class|
			data[component_class.to_s] = entity.get_component(component_class).serialize
		end
		data
	end
end