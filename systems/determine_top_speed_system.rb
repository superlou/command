class DetermineTopSpeedSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all TopSpeedComponent, ForceMakeupComponent)
	end

	def setup
		@top_speed_mapper = Artemis::ComponentMapper.new(TopSpeedComponent, @world)
		@force_makeup_component = Artemis::ComponentMapper.new(ForceMakeupComponent, @world)
	end

	def process_entity(entity)
		@top_speed_mapper.get(entity).top_speed = 60
	end
end