extends Node
class_name PlayerSM

@export var combat: HumanoidCombat
@export var area_awareness: AreaAwareness
@export var legs_sm: LegsSM

var player: Princess

@export var animator_manager: AnimatorManager
@export var animation_settings: AnimationPlayer

var current_state: PlayerState

@onready var container: PlayerStatesContainer = %StatesContainer

@export var SPEED: float = 3.0
@export var TURN_SPEED: float = 2.0

func initialise():
	var empty_input := InputPackage.new()

	# todo: better
	current_state = container.state_by_name(PS.run)
	legs_sm.current_behavior = container.legs_behavior_by_name(current_state.legs_behavior.behavior_name)
	legs_sm.current_action = container.legs_action_by_name(legs_sm.current_behavior.supported_actions.action_names[0])
	current_state.current_action = legs_sm.current_action
	legs_sm.current_behavior._on_enter_behavior(empty_input)

	current_state._on_enter_state(empty_input)

	animation_settings.play(A.SET_full_body, 0.2)


func update(input: InputPackage, delta: float) -> void:
	input = combat.contextualize(input)
	input = area_awareness.contextualize(input)
	area_awareness.last_input_package = input

	var verdict := current_state._check_transition(input)
	if verdict.comment:
		print_.psm("Final verdict ⚖️", "has something important to say:" + verdict.comment)
	if verdict.needs_switch():
		print('\n')
		print_.psm("↪️", current_state.state_name + " => " + verdict.next_state)
		
		current_state._on_exit_state()
		# now current_state is next state
		current_state = container.state_by_name(verdict.next_state)
		if current_state.state_name == PS.run:
			print()
		player.current_state = current_state # for something outside
		current_state._on_enter_state(input)


	# TODO: moved back here, Player States triggers _update from legs_animator behavior -> double dipping
	# current_state.update_resources(delta)
	current_state._update(input, delta)


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
