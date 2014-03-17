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