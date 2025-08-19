extends Node
class_name PlayerSM

@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var legs_sm: LegsSM

var player: Princess

# Fixed animator setup (we stick to SimpleAnimator_ now)
@export var torso_animator: SimpleAnimator_ # the Torso skeleton modifier
@export var animations_source: AnimationPlayer # clip library for torso actions (if actions read from here)
# @export var torso_anim_settings: AnimationPlayer # settings player if you ever need to fade torso influence
@export var animation_settings: AnimationPlayer # settings player if you ever need to fade torso influence


var current_state: PlayerState

@onready var container: PlayerStatesContainer = %StatesContainer

@export var SPEED: float = 3.0
@export var TURN_SPEED: float = 2.0

func initialise():
	var empty_input := InputPackage.new()

	current_state = container.state_by_name(PS.run)
	# current_state.current_action = container.action_by_name(PS.action_idle)

	# todo: better
	legs_sm.current_behavior = container.legs_behavior_by_name(current_state.legs_behavior.behavior_name)
	legs_sm.current_action = container.legs_action_by_name(legs_sm.current_behavior.supported_actions[0])
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

	var verdict := current_state.check_transition(input)
	if verdict != "okay":
		print_.prefix("PSM State", current_state.state_name + " => " + verdict)
		
		current_state._on_exit_state()
		# no current_state is next state
		current_state = container.state_by_name(verdict)
		player.current_state = current_state # for something outside
		current_state._on_enter_state(input)


	# TODO TODO: moved back here, TorsoStates triggers _update from legs_animator behavior -> doubledipping
	# current_state.update_resources(delta)
	current_state._update(input, delta)


## TODO: i dont fucking know there to put this function! 
##       also it is a hack, i dont know how to glue fancy camera with changing player velocity for now
func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
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
