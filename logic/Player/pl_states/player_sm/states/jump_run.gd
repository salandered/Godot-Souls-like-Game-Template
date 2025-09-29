extends PlayerState


var LAUNCH_TIMING = 0.0657 # When in animation the character actually leaves ground
var jumped := false

func on_enter_state(input: InputPackage) -> void:
	var anim: AnimationData = anim_container.get_by_name(current_action.anim_name)
	var marker := anim.get_marker_by_name(M.MarkerName.JUMP_LAUNCH)
	if marker:
		LAUNCH_TIMING = marker.time
	jumped = false
	player.velocity = player.velocity.normalized() * player.jump_data.jump_speed
	print_.psm("on enter " + state_name, str(player.jump_data))


func on_exit_state() -> void:
	print_.psm("on exit " + state_name, pp.ts("player.velocity.y", player.velocity.y))


func check_transition(input: InputPackage) -> PLVerdict:
	var treshhold = current_action.DURATION - 0.05
	if current_action.works_longer_than(treshhold):
		print_.psm_check_trans(state_name, pp.compare_w("Work longer than", "", treshhold) + "=> midair")
		return PLVerdict.new(PS.midair)
	return PLVerdict.new("")


func update(input: InputPackage, delta: float) -> void:
	if not jumped and current_action.works_longer_than(LAUNCH_TIMING):
		player.velocity.y += 2.5
		jumped = true
		print_.psm(state_name, "JUMPED! Setting physics_y_velocity to: " + str(player.jump_data.jump_speed))
	
	# move_with_hybrid_root(delta)
	
	# debug_velocities()

func move_with_hybrid_root(delta: float) -> void:
	# Get XZ root motion from animation (Y zeroed)
	# var xz_root_velocity := animator_manager.get_root_velocity(true)
	# Apply rotation to root motion
	# var xz_delta_pos = player.get_quaternion() * xz_root_velocity
	# Combine: XZ from root motion, Y from physics
	# player.velocity.x = xz_delta_pos.x
	# player.velocity.z = xz_delta_pos.z
	if jumped:
		player.velocity.y -= player.jump_data.jump_up_gravity * delta
	else:
		# Before jump, keep grounded
		player.velocity.y = -2.0 # Small downward to stay on floor

func debug_velocities() -> void:
	var xz_root = animator_manager.get_root_velocity(true)
	var rotated_xz = player.get_quaternion() * xz_root
	
	# print_.psm(state_name, pp.ts("state progress in sc ", current_action.get_progress()))
	# print_.psm(state_name, pp.ts("~~jumped: ", jumped, " physics_y_velocity: ", physics_y_velocity, " player.velocity.y: ", player.velocity.y))
	# print_.psm(state_name, pp.ts("~~xz_root: ", xz_root, " rotated_xz: ", rotated_xz))
	
	# Green arrow for XZ movement (from player position)
	var xz_end = player.global_position + Vector3(rotated_xz.x, 0, rotated_xz.z)
	DebugDraw3D.draw_arrow(
		player.global_position,
		xz_end,
		Color.GREEN,
		0.2
	)
	
	# Blue arrow for Y velocity (scale it down for visibility)
	if jumped:
		var y_end = player.global_position + Vector3(0, player.current_jump_velocity_y * 0.1, 0)
		DebugDraw3D.draw_arrow(
			player.global_position,
			y_end,
			Color.BLUE,
			0.2
		)

# region: If you want more control, you can also extract both Y and XZ components and blend them:
# func move_with_hybrid_root_advanced(delta: float) -> void:
# 	# Get full root motion including Y
# 	var full_root_velocity := animator_manager.get_root_velocity(false)
# 	# Get XZ-only root motion  
# 	var xz_root_velocity := animator_manager.get_root_velocity(true)
	
# 	# Extract just the Y component from animation
# 	var anim_y_velocity = full_root_velocity.y
	
# 	# Apply rotation
# 	var rotated_xz = player.get_quaternion() * xz_root_velocity
	
# 	# Blend animation Y with physics Y (optional - for subtle polish)
# 	var y_blend_factor = 0.2  # How much animation Y affects final Y
# 	var final_y = physics_y_velocity
# 	if not jumped:  # Before launch, use more animation
# 		final_y = lerp(physics_y_velocity, anim_y_velocity, 0.8)
# 	else:  # After launch, mostly physics with subtle anim influence
# 		final_y = lerp(physics_y_velocity, physics_y_velocity + anim_y_velocity, y_blend_factor)
	
# 	player.velocity = Vector3(rotated_xz.x, final_y, rotated_xz.z)
	
# 	# Update physics Y for next frame
# 	if jumped:
# 		physics_y_velocity -= up_gravity * delta
# endregion

# region: For comparison, here's how you'd organize states by their root motion needs:
# Base state class addition
# func move_with_root(delta: float, use_y: bool = false) -> void:
# 	var root_velocity := animator_manager.get_root_velocity(not use_y)
# 	player.velocity = player.get_quaternion() * root_velocity
	
# 	# Add gravity if we're ignoring animation Y
# 	if not use_y and not player.is_on_floor():
# 		player.velocity.y -= u.gravity * delta

# # Usage in different states:
# # attack.gd - Pure XZ root motion
# func update(input: InputPackage, delta: float) -> void:
# 	move_with_root(delta, false)  # XZ only
	
# # climb_ledge.gd - Full XYZ root motion  
# func update(input: InputPackage, delta: float) -> void:
# 	move_with_root(delta, true)  # Use animation Y
	
# # jump_start.gd - Hybrid
# func update(input: InputPackage, delta: float) -> void:
# 	move_with_hybrid_root(delta)  # Custom blend
# endregion

# Key Decision Points: When to use each approach

# Pure XZ Root Motion (Y physics):

	# Jump states (start, midair, land)
	# Normal movement (walk, run, sprint)
	# Combat moves that stay grounded

# Full XYZ Root Motion:

	# Climb/vault animations
	# Synchronized takedowns
	# Cutscene-like movements
	# Getting up from ragdoll

# No Root Motion (pure physics):

	# Midair state after jump
	# Knockback/damage reactions
	# Swimming/flying


# AS IT WAS
# var VERTICAL_SPEED_ADDED: float = 2.5

# # values based on animation jump_run
# const TRANSITION_TIMING = 0.44
# const JUMP_TIMING = 0.1

# var jumped: bool = false

# func _ready() -> void:
# 	SPEED = 3.0

# func check_transition(input: InputPackage) -> PLVerdict:
# 	if current_action.works_longer_than(TRANSITION_TIMING):
# 		jumped = false
# 		return PLVerdict.new(PS.midair)
# 	else:
# 		return PLVerdict.new("")

# func on_enter_state(input: InputPackage) -> void:
# 	player.velocity = player.velocity.normalized() * SPEED

# func update(input: InputPackage, delta: float) -> void:
# 	if current_action.works_longer_than(JUMP_TIMING):
# 		if not jumped:
# 			#player.velocity = player.basis.z * SPEED
# 			player.velocity.y += VERTICAL_SPEED_ADDED
# 			jumped = true
