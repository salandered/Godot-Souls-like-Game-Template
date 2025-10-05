# small_jump_run.gd
extends PlayerState

# Animation timings
var TAKEOFF_TIME := 0.35 # When we actually leave ground
var LANDING_TIME := 1.1 # When first foot touches down

# Jump parameters (easily tweakable)
var JUMP_VELOCITY_Y := 1.8 # Lower than regular jump's 2.5
var FORWARD_SPEED := 3.0 # Maintain run speed
var AIR_CONTROL_STRENGTH := 0.12 # Subtle air control

# State tracking
var phase := "prep" # "prep", "airborne", "recovery"
var initial_forward_dir: Vector3

func on_enter_state(input: InputPackage) -> void:
	phase = "prep"
	# Capture current movement direction
	initial_forward_dir = player.velocity.normalized()
	if initial_forward_dir.length() < 0.1:
		initial_forward_dir = player.basis.z
	
	# Maintain forward momentum
	player.velocity = initial_forward_dir * FORWARD_SPEED
	player.velocity.y = -2.0 # Slight downward to stay grounded during prep


func on_exit_state() -> void:
	# Ensure we're grounded when exiting
	if player.velocity.y > 0:
		player.velocity.y = 0


func update(input: InputPackage, delta: float) -> void:
	var time = current_action.time_spent()
	
	# Phase transitions based on animation timing
	if phase == "prep" and time >= TAKEOFF_TIME:
		phase = "airborne"
		player.velocity.y = JUMP_VELOCITY_Y
		print_.psm(state_name, "Takeoff! Y velocity: " + str(JUMP_VELOCITY_Y))
	elif phase == "airborne" and time >= LANDING_TIME:
		phase = "recovery"
		player.velocity.y = -2.0 # Stick to ground
		print_.psm(state_name, "Landed!")
	
	# Phase-specific behavior
	match phase:
		"prep":
			# Still on ground, maintain forward motion
			keep_forward_momentum(delta)
		
		"airborne":
			# Apply gravity
			player.velocity.y -= player.jump_data.jump_fall_gravity * delta
			# Air control
			apply_air_control(input, delta)
		
		"recovery":
			# On ground, blend back to run
			keep_forward_momentum(delta)

func keep_forward_momentum(delta: float) -> void:
	# Option 1: Use root motion XZ if animation has it
	var xz_root = animator_manager.get_root_velocity(true)
	if xz_root.length() > 0.1:
		player.velocity.x = (player.get_quaternion() * xz_root).x
		player.velocity.z = (player.get_quaternion() * xz_root).z
	# Option 2: Otherwise maintain speed
	else:
		var current_xz = Vector3(player.velocity.x, 0, player.velocity.z)
		if current_xz.length() < FORWARD_SPEED * 0.5:
			player.velocity.x = initial_forward_dir.x * FORWARD_SPEED
			player.velocity.z = initial_forward_dir.z * FORWARD_SPEED

func apply_air_control(input: InputPackage, delta: float) -> void:
	var input_dir := velocity_by_input(input, delta)
	input_dir.y = 0
	input_dir = input_dir.normalized()
	
	if input_dir.length() < 0.1:
		return
	
	var current_xz = Vector3(player.velocity.x, 0, player.velocity.z)
	var current_speed = current_xz.length()
	
	# Redirect without changing speed much
	var target_velocity = input_dir * current_speed
	current_xz = current_xz.lerp(target_velocity, AIR_CONTROL_STRENGTH * delta)
	
	player.velocity.x = current_xz.x
	player.velocity.z = current_xz.z

func check_transition(input: InputPackage) -> PLVerdict:
	# Exit when animation completes
	if current_action.time_remaining() < 0.05:
		return PLVerdict.new(PS.run)
	if not player.is_on_floor() and phase == 'recovery':
		return PLVerdict.new(PS.midair)
	
	return PLVerdict.new("")
