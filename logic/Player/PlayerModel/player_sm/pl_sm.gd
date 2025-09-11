extends Node
class_name PlayerSM

@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var legs_sm: LegsSM

var player: Princess

# Fixed animator setup (we stick to ModifierAnimator now)
@export var torso_animator: ModifierAnimator # the Torso skeleton modifier
@export var legs_animator: ModifierAnimator
@export var animations_source: AnimationPlayer # clip library for torso actions (if actions read from here)
# @export var torso_anim_settings: AnimationPlayer # settings player if you ever need to fade torso influence
@export var animation_settings: AnimationPlayer # settings player if you ever need to fade torso influence

var current_state: PlayerState

@onready var container: PlayerStatesContainer = %StatesContainer

@export var SPEED: float = 3.0
@export var TURN_SPEED: float = 2.0

func initialise():
	var empty_input := InputPackage.new()

	# todo: better
	current_state = container.state_by_name(PS.run)
	legs_sm.current_behavior = container.legs_behavior_by_name(current_state.legs_behavior.behavior_name)
	legs_sm.current_action = container.legs_action_by_name(legs_sm.current_behavior.supported_actions[0])
	current_state.current_action = legs_sm.current_action
	legs_sm.current_behavior._on_enter_behavior(empty_input)

	current_state._on_enter_state(empty_input)

	animation_settings.play(A.SET_torso_legs, 0.2)


func update(input: InputPackage, delta: float) -> void:
	# if fly_mode_enabled:
	# 	_handle_fly_mode(input, delta)
	# 	return
	input = combat.contextualize(input)
	input = area_awareness.contextualize(input)
	area_awareness.last_input_package = input

	var verdict := current_state._check_transition(input)
	if verdict != "okay":
		print_.prefix("PSM ↪️", current_state.state_name + " => " + verdict)
		
		current_state._on_exit_state()
		# now current_state is next state
		current_state = container.state_by_name(verdict)
		player.current_state = current_state # for something outside
		current_state._on_enter_state(input)


	# TODO TODO: moved back here, TorsoStates triggers _update from legs_animator behavior -> doubledipping
	# current_state.update_resources(delta)
	current_state._update(input, delta)


## TODO: i dont fucking know there to put this function! 
##       also it is a hack, i dont know how to glue fancy camera with changing player velocity for now
func __velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	var _velocity := Vector3.ZERO
	var forward_speed := input.forward_input
	var orbit_speed := input.orbit_input

	if legs_sm.area_awareness.is_camera_locked():
		forward_speed *= -1
		orbit_speed *= -1
	
	var grounded_target: Vector3
	if legs_sm.area_awareness.is_camera_locked():
		grounded_target = player.fancy_camera.locked_target.global_position
	else:
		grounded_target = player.fancy_camera.nest.global_position
	grounded_target.y = player.global_position.y

	if forward_speed != 0.0:
		_velocity -= player.global_position.direction_to(grounded_target) \
					 * forward_speed * SPEED

	if orbit_speed != 0.0:
		var d: float = orbit_speed * SPEED * delta
		var target_direction := grounded_target - player.global_position
		var distance_to_target := target_direction.length()
		var alpha := -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha)
		var d_vector := grounded_target - rotated_dir - player.global_position
		_velocity += d_vector / delta
	return _velocity


	# TEST
	# var velocity = player.velocity
	# var raw_input := Input.get_vector(RawAction.move_left, RawAction.move_right, RawAction.move_forward, RawAction.move_back)
	# var move_speed := 8.0
	# var acceleration := 4.0
	# var stopping_speed := 1.0
	# var _move_direction := Vector3.ZERO
	# # This is to ensure that diagonal input isn't stronger than axis aligned input
	# _move_direction.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	# _move_direction.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	# _move_direction = player.fancy_camera.camera.global_transform.basis * _move_direction
	# _move_direction.y = 0.0
	# var y_velocity = velocity.y
	# velocity.y = 0.0
	# velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	# if _move_direction.length() == 0 and velocity.length() < stopping_speed:
	# 	velocity = Vector3.ZERO
	# velocity.y = 0
	# return velocity
	# TEST END