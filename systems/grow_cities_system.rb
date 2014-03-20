class GrowCitiesSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all LocationComponent, NameComponent, PopulationComponent)
	end

	def setup
		@population_mapper = Artemis::ComponentMapper.new(PopulationComponent, @world)
	end

	def process_entity(entity)
		current_population = @population_mapper.get(entity).population
		new_population = current_population * 1.00001
		@population_mapper.get(entity).population = new_population
	end
end