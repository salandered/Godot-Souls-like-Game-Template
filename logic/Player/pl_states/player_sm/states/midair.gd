extends PlayerState

var landing_height: float = 0.5


var air_control_strength := 0.15
var terminal_velocity := -20.0

var peak_reached := false

func on_enter_state(input_: InputPackage) -> void:
	peak_reached = player.velocity.y <= 0
	print_.psm(pp.on_ent + state_name, pp.s("peak_reached", peak_reached,
	"jump_fall_gravity", player.jump_data.jump_fall_gravity,
	"jump_up_gravity", player.jump_data.jump_up_gravity))
	

func update(input_: InputPackage, delta: float) -> void:
	# Continue using the shared velocity variable
	if player.velocity.y > 0.1:
		player.velocity.y -= player.jump_data.jump_up_gravity * delta
	else:
		if not peak_reached:
			peak_reached = true
		player.velocity.y -= player.jump_data.jump_fall_gravity * delta
	
	player.velocity.y = max(player.velocity.y, terminal_velocity)
	
	# Air control
	apply_air_control(input_, delta)
	
	debug_velocities()
	# print_.psm(state_name, pp.s("player vel:", pp.pp_vec3(player.velocity), "peak_reached", peak_reached))


func apply_air_control(input_: InputPackage, delta: float) -> void:
	var input_dir := velocity_by_input(input_, delta)
	input_dir.y = 0
	input_dir = input_dir.normalized()
	
	if input_dir.length() < 0.1:
		return
	
	var current_xz := Vector3(player.velocity.x, 0, player.velocity.z)
	var current_speed := current_xz.length()
	
	# Subtle redirection without speed increase
	var target_velocity := input_dir * current_speed
	current_xz = current_xz.lerp(target_velocity, air_control_strength * delta)
	
	player.velocity.x = current_xz.x
	player.velocity.z = current_xz.z


func check_transition(input_: InputPackage) -> PLVerdict:
	var floor_distance := area_awareness.get_floor_distance()
	
	if floor_distance < landing_height and peak_reached:
		print_.psm_check_trans(state_name, pp.compare("<", "floor_distance", floor_distance, "landing_height", landing_height) + "=> landing_run")
		var xz_speed := Vector3(player.velocity.x, 0, player.velocity.z).length()
		
		# Heavy landing check
		if player.velocity.y < -15.0:
			return PLVerdict.new(PS.landing_sprint) # PS.landing_heavy) # If you have this state
		elif xz_speed > 1.0:
			return PLVerdict.new(PS.landing_sprint)
		else:
			return PLVerdict.new(PS.landing_sprint) # PS.landing_idle) # If you have this
	
	# Calculate time until landing based on current fall speed
	# var time_to_impact = floor_distance / abs(player.velocity.y) if player.velocity.y < 0 else 999
	
	# # Trigger landing animation early (0.2s before impact)
	# if time_to_impact < 0.2 and player.velocity.y < 0:
	# 	  print_.psm("midair", pp.s("Pre-landing trigger: ", time_to_impact, "s to impact"))
		# return PLVerdict.new(PS.landing_sprint)
	return PLVerdict.new("")


func debug_velocities() -> void:
	var current_xz := Vector3(player.velocity.x, 0, player.velocity.z)
	
	# Green arrow for XZ movement (from player position)
	var xz_end := player.global_position + Vector3(current_xz.x, 0, current_xz.z)
	DebugDraw3D.draw_arrow(
		player.global_position,
		xz_end,
		Color.GREEN,
		0.2
	)
	
	# Blue arrow for Y velocity (scale it down for visibility)
	var y_end: = player.global_position + Vector3(0, player.velocity.y * 0.1, 0)
	DebugDraw3D.draw_arrow(
		player.global_position,
		y_end,
		Color.BLUE,
		0.2
	)

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
