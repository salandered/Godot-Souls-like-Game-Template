extends Node
class_name BasePlayerState


var player: CharacterBody3D

var resources: HumanoidResources

# unique fields to redefine
@export var animation: String
@export var backend_animation: String
@export var animator: AnimationPlayer

var state_name: String # deleted in episode 4...

# I can tolerate up to two _costs, 
# the moment I need a third one, I'll create a small ResourceCost class to pay them.
@export var stamina_cost: float = 0

# general fields for internal usage
@onready var combos: Array[Combo]

var enter_state_time: float

# TODO: has_queued_state and queued_state can be one var (probably)
# or queued_state is an array (wow)
var has_queued_state: bool = false
var queued_state: String = "none, drop error please"

var has_forced_state: bool = false
var forced_state: String = "none, drop error please"

const SPEED = 3.0
@export var RUN_SPEED: float = 5.0

## parameters windows incorporation way N2
# here and below in methods because I chose this way
var states_data_repo: StatesDataRepository


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

# region: FAIR DOCS: General States heir usage guide.

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


# When a transition occurs, we ask three questions: 
# 1. does something from the past force us to transition somewhere? 
# 2. If not, does something textual from the present modify our inputs? 
# 3. if nothing above, what vanilla state wants to default to?
func check_relevance(input: InputPackage) -> String:
	if has_forced_state:
		has_forced_state = false
		return forced_state
	# nah, too early
	check_combos(input) # but we need to individually deny combos
	# too late
	return default_lifecycle(input) # and also to work in updates sometime


## docs from Ep. 3
## If state can invoke a combo in its transition logic, it asks its combos if they are triggered.
## If they are, they store the triggered action into a 'queued state' field.
## => states can use 'queued state' field for transitions without losing it.
func check_combos(input: InputPackage):
	for combo: Combo in combos:
		# print("COMBO", combo.triggered_state)
		if combo.is_triggered(input) and resources.can_be_paid(player.model.states[combo.triggered_state]):
			has_queued_state = true
			queued_state = combo.triggered_state

## choosing the input with the highest priority that we can also pay for
func best_input_that_can_be_paid(input: InputPackage) -> String:
	var sorted_actions := PlayerState.sort_by_priority(input.actions)
	# print("--- after sort_by_priority ", sorted_actions)
	for action: String in sorted_actions:
		if resources.can_be_paid(player.model.states[action]):
			if player.model.states[action] == self:
				return "okay"
			else:
				return action
	return "throwing because for some reason input.actions doesn't contain even idle"

## Updating may be not too far from current state updating: regeneration could be dependent on the current state.
## => define the base state `update_resources` function with delegating the job to the resources.
## -> default regenerations can be defined in the resource class, but it's possible to redefine this function in some states.
## 		for example, to stop stamina from regenerating under a shield block.
func update_resources(delta: float):
		resources.update(delta)


# INTERFACE METHODS
func default_lifecycle(_input: InputPackage) -> String:
	# can return idle, but I want this error to be thrown to make future's life easier
	return "implement default lyfecycle pepega " + animation

func update(_input: InputPackage, _delta: float):
	pass

func on_enter_state():
	pass

func on_exit_state():
	pass
# END INTERFACE METHODS

func assign_combos():
	for child in get_children():
		if child is Combo:
			combos.append(child)
			child.state = self # combo.state here

## overidden in states
func pack_hit_data(_weapon: WeaponOh) -> HitData:
	print("someone tries to get hit by default State")
	return HitData.blank()

# GET MODIFIERS BASED ON ANIMATION
func is_vulnerable() -> bool:
	return states_data_repo.get_vulnerable(backend_animation, get_progress())

func is_interruptable() -> bool:
	return states_data_repo.get_interruptable(backend_animation, get_progress())

func is_parryable() -> bool:
	return states_data_repo.get_parryable(backend_animation, get_progress())


# DEFAULT BEHAVIOURS ON MODIFIERS
#  - most of our states react on being hit universally
#    they check for interruptibility frames and do stagger (or don't). 
func react_on_hit(hit: HitData):
	if is_vulnerable():
		resources.lose_health(hit.damage)
	if is_interruptable():
		try_force_state("staggered")
	hit.queue_free()

# Eg: every parriable weapon strike transitions into a single "parry" state on successful parry
func react_on_parry(_hit: HitData):
	try_force_state("parried")

func try_force_state(new_forced_state: String):
	if not has_forced_state:
		has_forced_state = true
		forced_state = new_forced_state
	elif PlayerState.states_priority[new_forced_state] >= PlayerState.states_priority[forced_state]:
		forced_state = new_forced_state


## needed in states like run and sprint. will be here for now
func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
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


# TIME MANAGEMENT
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
# END TIME MANAGEMENT
