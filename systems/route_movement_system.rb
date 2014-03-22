class RouteMovementSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all TopSpeedComponent, MovementGoalComponent, LocationComponent)
	end

	def setup
		@location_mapper = Artemis::ComponentMapper.new(LocationComponent, @world)
	end

	def process_entity(entity)
		#puts "process #{entity}"
	end
end