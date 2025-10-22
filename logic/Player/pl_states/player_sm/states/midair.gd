extends PlayerState

var landing_height: float = 0.5


func check_transition(input_: InputPackage) -> PLVerdict:
	var floor_distance := area_awareness.get_floor_distance()
	
	if floor_distance < landing_height:
		__log_psm_check("floor_dist", floor_distance, "< land height", landing_height, "=> landing_sprint")
		return PLVerdict.new(PS.landing_sprint)
	
	return PLVerdict.new("")


# region: AS IT WAS
# 
# var DELTA_VECTOR_LENGTH: float = 0.30
# var jump_direction: Vector3 = Vector3.ZERO
# func check_transition(input_: InputPackage) -> PLVerdict:
# 	var floor_distance := area_awareness.get_floor_distance()
# 	if floor_distance < landing_height:
# 		var xz_velocity = player.velocity
# 		xz_velocity.y = 0
# 		if xz_velocity.length_squared() >= 10:
# 			return PLVerdict.new(PS.landing_sprint) # TODO WAS SPRINT
# 		print_.psm_check_trans(state_name, str(floor_distance) + " < " + str(landing_height) + " => landing_run")
# 		return PLVerdict.new(PS.landing_sprint)
# 	else:
# 		# print_.psm("midair", "still midair")
# 		# still falling
# 		return PLVerdict.new("")

# func on_enter_state(input_: InputPackage) -> void:
# 		# the clamp construction is here to 
# 		# 1) prevent look_at annoying errors when our velocity is zero and it can't look_at properly
# 		# 3) have a way to scale from velocity. The longer the vector is, the harder it is to modify it by adding a delta.
# 		#    Scaling jump_direction with velocity is giving us that natural behavior of faster jumps (sprints)
# 		#    being less controllable, and jumps from standing position being more volatile.
# 		#    The dependance on velocity paramter is not critical, delete this if you don't like the approach.
# 	jump_direction = Vector3(player.basis.z) * clamp(player.velocity.length(), 1, 999999)
# 	jump_direction.y = 0

	
# func update(input_: InputPackage, delta: float) -> void:
# 	player.velocity.y -= u.gravity * delta
# 	current_action.update(input_, delta)


# ## Divide velocity and look direction
# func process_input_vector(input_: InputPackage, delta: float):
# 	var input_direction := velocity_by_input(input_, delta).normalized()
# 	var input_delta_vector = input_direction * DELTA_VECTOR_LENGTH
	
# 	# ep 6: (jump_direction + input_delta_vector * delta).limit_length(clamp(player.velocity.length(), 1, 999999))
# 	jump_direction = (jump_direction + input_delta_vector).limit_length(player.velocity.length())
# 	u.safe_look_at(player, player.global_position - jump_direction)

# 	# ep 6: (player.velocity + input_delta_vector * delta).limit_length(player.velocity.length())
# 	var new_velocity = (player.velocity + input_delta_vector).limit_length(player.velocity.length())
# 	player.velocity = new_velocity
# endregion
