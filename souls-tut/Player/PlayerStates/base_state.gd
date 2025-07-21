extends Node
class_name BasePlayerState


# all-states variables here
var player: CharacterBody3D

# unique fields to redefine
var animation: String
var state_name: String
var has_queued_state: bool = false
var queued_state: String = "none, drop error please"

# general fields for internal usage
var enter_state_time: float
const SPEED = 3.0
@export var RUN_SPEED: float = 5.0

static func states_priority_sort(a: String, b: String):
	if PlayerState.states_priority[a] > PlayerState.states_priority[b]:
		return true
	else:
		return false

# There is a wall of text as a general guide on this function in the end of the page, 
# because I'm too lazy to write proper docs for a "tutorial" project
func check_relevance(_input: InputPackage) -> String:
	print_debug("error, implement the check_relevance function on your state")
	return "error, implement the check_relevance function on your state"


func update(_input: InputPackage, _delta: float):
	pass


func on_enter_state():
	pass

func on_exit_state():
	pass


func check_combos(input: InputPackage):
	# works if only children we have are combos, use defined on ready array if not
	var available_combos = get_children()
	for combo: Combo in available_combos:
		if combo.is_triggered(input):
			has_queued_state = true
			queued_state = combo.triggered_state


func mark_enter_state():
	enter_state_time = Time.get_unix_time_from_system()

func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_state_time

func works_longer_than(time: float) -> bool:
	if get_progress() >= time:
		return true
	return false

func works_less_than(time: float) -> bool:
	if get_progress() < time:
		return true
	return false

func works_between(start: float, finish: float) -> bool:
	var progress = get_progress()
	if progress >= start and progress <= finish:
		return true
	return false


func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	# needed in states like run and sprint. will be here for now
	var _velocity = Vector3.ZERO
	var forward_speed = input.forward_input
	var orbit_speed = input.orbit_input

	if player.fancy_camera.is_target_locked:
		forward_speed *= -1
		orbit_speed *= -1

	var grounded_target: Vector3
	if player.fancy_camera.is_target_locked and player.fancy_camera.locked_target:
		grounded_target = player.fancy_camera.locked_target.global_position
	else:
		grounded_target = player.fancy_camera.camera_nest.global_position
	grounded_target.y = player.global_position.y
	
	if forward_speed != 0.0:
		# var grounded_target := fancy_camera.camera_nest.global_position
		# grounded_target.y = player.global_position.y
		_velocity -= player.global_position.direction_to(grounded_target) * forward_speed * RUN_SPEED

	if orbit_speed != 0.0:
		var d: float = orbit_speed * RUN_SPEED * delta
		# var grounded_target := fancy_camera.camera_nest.global_position
		# grounded_target.y = player.global_position.y

		var target_direction := grounded_target - player.global_position # R1
		var distance_to_target := target_direction.length()
		var alpha = -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha) # R2
		var orb_pt = grounded_target + rotated_dir
		var d_vector := grounded_target - rotated_dir - player.global_position
		_velocity += d_vector / delta

	return _velocity.limit_length(RUN_SPEED)

# region: original velocity_by_input for RUN
# func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
# 	var new_velocity = player.velocity
	
# 	var direction = (player.camera_mount.basis * Vector3(-input.input_direction.x, 0, -input.input_direction.y)).normalized()
# 	new_velocity.x = direction.x * SPEED
# 	new_velocity.z = direction.z * SPEED
	
# 	if not player.is_on_floor():
# 		new_velocity.y -= gravity * delta
	
# 	return new_velocity
# endregion

# region: General States heir usage guide.

# > check_relevance function aims to be short and simple.
# 	Its general structure is as follows: 
#	if (state is ready to transition) :
#		transition to the highest priority out there
#	else:
#		return "okay" to save our managing status.
#
# 	BasePlayerState readyness for transition is generally a simple function based on timings or statuses of the player.
#	If you are starting to understand that your transition readyness is a complex method, OR
# 	if you are tempted to add third branching operator into your check_relevance function,
#	seriously consider if Combo can do this logic for you, you won't regret its usage I promise.
#	(Combo is clickable even from comments btw)

# > update functions manages perframe behaviour of your BasePlayerState.
#	There are two update types: constant change and a single dynamic update on some timing.
#	To implement simple constant changes, try to find some physics abstraction for them to make
#	engine work for you. If your constant changes are too complex, try to avoid hardcoding 
#	the behaviour into a giant update, better shove the changes data into a backend animation or
#	some other data structure resource.
#	To implement timed changes, use a flag and work with timings via get_progress() and Co.
#	To roughly base your internal timings on the players behaviour, you can check skeleton
#	animation for reference. But for the love of god please avoid referensing skeleton and animator
#	in any shape way or form in the States code directly. This way your BasePlayerState "backend" is free from
#	thousand different ways someone (probably you from the future) can mess up your skeleton, scene composition,
#	animations, names libraries etc.

# extends Node
# class_name PlayerBaseState


# var player: CharacterBody3D


#  # transition logic
# func check_relevance(input_data: InputData) -> String:
# 	# todo - current check_relevance s in states look not optimized
# 	print_debug("error, implement the check_relevance function on your state")
# 	return "error, implement the check_relevance function on your state"


# func update(input_data: InputData, delta: float):
# 	pass

# func on_enter_state():
# 	pass

# func on_exit_state():
# 	pass
#
# endregion
