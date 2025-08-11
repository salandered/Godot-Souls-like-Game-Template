extends Node
class_name PlayerModel

# todo consider: not a fan of sharing logic between enemy/player

@onready var player: Princess = $".."
@onready var skeleton = %GeneralSkeleton
@onready var animator = $SplitBodyAnimator
@onready var combat = $Combat as HumanoidCombat
@onready var resources = $Resources as HumanoidResources
@onready var hitbox: Hitbox_ = %HitBox
@onready var legs_manager = $LegsManager as LegsManager
@onready var area_awareness = $AreaAwareness as AreaAwareness

@onready var active_weapon: SwordOh = %SwordOh
@onready var states_container = $StatesContainer as PlayerStatesContainer
# @onready var weapons = {
# 	"sword" = $....Sword,
# 	"bow" = $....Bow,
# 	"greatsword" = $....Greatsword,
# 	....
# }

var current_state: BasePlayerState


func _ready():
	states_container.player = player
	states_container.accept_states()
	current_state = states_container.states["idle"]
	switch_to("idle")
	
	legs_manager.current_legs_state = states_container.get_state_by_name("idle")
	legs_manager.accept_behaviours()


func update(input: InputPackage, delta: float):
	if fly_mode_enabled:
		_handle_fly_mode(input, delta)
		return

	input = combat.contextualize(input)
	input = area_awareness.contextualize(input)
	area_awareness.last_input_package = input
	var verdict = current_state.check_transition(input)
	if verdict != "okay": # todo not okay
		switch_to(verdict)

	# TODO TODO: moved back here, TorsoStates triggers _update from legs behaviour -> doubledipping
	current_state.update_resources(delta)
	
	current_state._update(input, delta)


func switch_to(state: String):
	# print(current_state.state_name + " -> " + state)
	current_state._on_exit_state()
	current_state = states_container.states[state]
	current_state._on_enter_state()


var fly_mode_enabled := false
var fly_speed := 15

func _handle_fly_mode(input: InputPackage, delta: float):
	# var input_direction = (player.camera_mount.basis * Vector3(-input.input_direction.x, 0, -input.input_direction.y)).normalized()
	# todo: this is that strange valocity chain
	var tracking_angular_speed := 4
	var input_direction := velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	player.rotate_y(clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))

	# Normalize and scale
	if input_direction != Vector3.ZERO:
		input_direction = input_direction.normalized() * fly_speed

	player.velocity = input_direction
	if input.actions.has(PlayerState.jump_run):
		player.velocity.y += 5
	if input.combat_actions.has(InDataCombatAction.heavy_attack_pressed):
		player.velocity.y -= 5

	
	player.move_and_slide() # No gravity by default unless applied manually


func __toggle_fly_mode():
	fly_mode_enabled = !fly_mode_enabled
	if fly_mode_enabled:
		player.velocity = Vector3.ZERO
	print("*** Fly mode: ", fly_mode_enabled)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dev_fly_mode"):
		__toggle_fly_mode()

	if event.is_action_released("dev_speed_up"):
		fly_speed += 5
	if event.is_action_released("dev_speed_down"):
		fly_speed -= 5

func velocity_by_input(input: InputPackage, delta: float) -> Vector3:
	var _velocity := Vector3.ZERO
	var forward_speed := input.forward_input


	var orbit_speed := input.orbit_input

	var grounded_target: Vector3
	grounded_target = player.fancy_camera.nest.global_position
	grounded_target.y = player.global_position.y

	if forward_speed != 0.0:
		_velocity -= player.global_position.direction_to(grounded_target) \
					 * forward_speed * 5

	if orbit_speed != 0.0:
		var d: float = orbit_speed * 5 * delta
		var target_direction := grounded_target - player.global_position
		var distance_to_target := target_direction.length()
		var alpha := -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha)
		var d_vector := grounded_target - rotated_dir - player.global_position
		_velocity += d_vector / delta
	return _velocity
