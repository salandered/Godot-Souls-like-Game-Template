# landing_run.gd - running landing
extends PlayerState


# Animation: [Prep in air][Leg1→Leg2][--Running--]
# Time:       0.0        0.2       0.35         0.55
# 		       ↑           ↑         ↑            ↑
# 	      Enter state   Contact  Control      Can exit
# 		   					      returns      to run

# Phases:    [pre_landing][-------running-------]
# Physics:   [Falling]    [Root motion → Input]

# Animation timing
@export var pre_landing_duration := 0.21 # Airborne preparation
@export var impact_duration := 0.18 # Both feet contact, absorbing

# Physics
@export var momentum_preservation := 0.85 # Higher - we're maintaining run
@export var min_run_speed := 2.0 # Below this, transition to idle instead
@export var control_return_time := 0.25 # After first foot contact + some impact

var landing_phase := "pre_landing"
var has_control := false

func on_enter_state(input: InputPackage) -> void:
	landing_phase = "pre_landing"
	has_control = false
	
	# Still falling during prep
	print_.psm("enter " + state_name, "Starting pre-landing")

func update(input: InputPackage, delta: float) -> void:
	if landing_phase == "pre_landing":
		# Continue falling while playing prep animation
		player.velocity.y -= player.jump_data.jump_fall_gravity * delta
		
		# Keep forward momentum
		apply_air_control(input, delta)
		
		# Check ground contact
		if player.is_on_floor() or area_awareness.get_floor_distance() < 0.05:
			landing_phase = "running"
			on_ground_contact()
			
	elif landing_phase == "running":
		# On ground, maintaining forward movement
		player.velocity.y = -2.0 # Stick to ground
		
		# Use root motion until control returns
		if not has_control and current_action.works_longer_than(control_return_time):
			var xz_root = animator_manager.get_root_velocity(true)
			var xz_delta = player.get_quaternion() * xz_root
			player.velocity.x = xz_delta.x
			player.velocity.z = xz_delta.z
		else:
			has_control = true
			process_input_vector(input, delta)

func on_ground_contact() -> void:
	# Impact moment - adjust momentum but keep moving
	player.velocity.y = 0
	
	# Less momentum loss since we're running through it
	var impact_factor = clamp(abs(player.velocity.y) / 20.0, 0.7, 1.0)
	player.velocity.x *= momentum_preservation * impact_factor
	player.velocity.z *= momentum_preservation * impact_factor
	
	print_.psm("CONTACT", pp.s("impact_vel", player.velocity.y, "xz_speed", Vector3(player.velocity.x, 0, player.velocity.z).length()))

func check_transition(input: InputPackage) -> PLVerdict:
	# Can transition once we're through impact and into run blend
	if landing_phase == "running" and current_action.works_longer_than(current_action.DURATION - 0.2):
		var xz_speed = Vector3(player.velocity.x, 0, player.velocity.z).length()
		
		if xz_speed > min_run_speed:
			return PLVerdict.new(PS.run)
		else:
			return PLVerdict.new(PS.run)
	
	return PLVerdict.new("")

func apply_air_control(input: InputPackage, delta: float) -> void:
	# Minimal air control during pre-landing
	var input_dir := velocity_by_input(input, delta)
	input_dir.y = 0
	input_dir = input_dir.normalized()
	
	if input_dir.length() > 0.1:
		var current_xz = Vector3(player.velocity.x, 0, player.velocity.z)
		current_xz = current_xz.lerp(input_dir * current_xz.length(), 0.1 * delta)
		player.velocity.x = current_xz.x
		player.velocity.z = current_xz.z