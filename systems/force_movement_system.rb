class ForceMovementSystem < Artemis::EntityProcessingSystem
	def initialize
		super(Artemis::Aspect.new_for_all MovementGoalComponent, TopSpeedComponent, LocationComponent)
	end

	def setup
		@movement_goal_mapper = Artemis::ComponentMapper.new(MovementGoalComponent, @world)
		@top_speed_mapper = Artemis::ComponentMapper.new(TopSpeedComponent, @world)
		@location_mapper = Artemis::ComponentMapper.new(LocationComponent, @world)
	end

	def process_entity(entity)
		movement_goal = @movement_goal_mapper.get(entity)
		location = @location_mapper.get(entity)
		goal_lat = movement_goal.lat
		goal_lon = movement_goal.lon
		current_lat = location.lat
		current_lon = location.lon

		top_speed = @top_speed_mapper.get(entity).top_speed_meters_per_second
		coverable_distance = top_speed * @world.delta

		distance = distance_from_points(current_lat, current_lon, goal_lat, goal_lon)

		if coverable_distance > distance
			location.lat = goal_lat
			location.lon = goal_lon
			entity.remove_component(movement_goal)
			entity.add_to_world
		else
			bearing = bearing_from_points(current_lat, current_lon, goal_lat, goal_lon)
			new_point = move_by_distance_and_bearing(current_lat, current_lon, coverable_distance, bearing)

			location.lat = new_point[0]
			location.lon = new_point[1]
		end
	end

	def distance_from_points(lat1, lon1, lat2, lon2)
		lat1 = to_rad(lat1)
		lon1 = to_rad(lon1)
		lat2 = to_rad(lat2)
		lon2 = to_rad(lon2)

		dLat = lat2 - lat1
		dLon = lon2 - lon1

		earth_radius = 6371.0e3
		a = Math.sin(dLat/2) * Math.sin(dLat/2) +
			Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

		earth_radius * c
	end

	def bearing_from_points(lat1, lon1, lat2, lon2)
		lat1 = to_rad(lat1)
		lon1 = to_rad(lon1)
		lat2 = to_rad(lat2)
		lon2 = to_rad(lon2)

		dLat = lat2 - lat1
		dLon = lon2 - lon1

		y = Math.sin(dLon) * Math.cos(lat2)
		x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon)
		bearing = Math.atan2(y, x)
	end

	def move_by_distance_and_bearing(lat1, lon1, d, b)
		lat1 = to_rad(lat1)
		lon1 = to_rad(lon1)

		earth_radius = 6371.0e3

		lat2 = Math.asin(
				Math.sin(lat1) * Math.cos(d/earth_radius) +
				Math.cos(lat1) * Math.sin(d/earth_radius) * Math.cos(b)
		)
		lon2 = lon1 + Math.atan2(
			Math.sin(b) * Math.sin(d/earth_radius) * Math.cos(lat1),
			Math.cos(d/earth_radius) - Math.sin(lat1) * Math.sin(lat2)
		)

		return [to_deg(lat2), to_deg(lon2)]
	end

	def to_rad(deg)
		deg * Math::PI / 180.0
	end

	def to_deg(rad)
		rad * 180.0 / Math::PI
	end
end