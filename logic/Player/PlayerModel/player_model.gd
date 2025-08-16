extends Node
class_name PlayerModel

@onready var player: Princess = $".."
@onready var skeleton = %GeneralSkeleton
# @onready var animator = $SplitBodyAnimator
@onready var combat = $Combat as HumanoidCombat
@onready var resources = $Resources as HumanoidResources
@onready var hitbox: Hitbox_ = %HitBox
@onready var area_awareness = $AreaAwareness as AreaAwareness

@onready var active_weapon: SwordOh = %SwordOh
@onready var container = %StatesContainer as PlayerStatesContainer
# @onready var weapons = {
# 	"sword" = $....Sword,
# 	"bow" = $....Bow,
# 	"greatsword" = $....Greatsword,
# 	....
# }
@onready var meta: SkeletonModifierMeta = %Meta
@onready var full_body: SimpleAnimator_ = %FullBody
@onready var torso: SimpleAnimator_ = %Torso
@onready var legs_animator: SimpleAnimator_ = %Legs

var current_state: PlayerState

@onready var player_sm: PlayerSM = %PlayerSM
@onready var legs_sm: LegsSM = %LegsSM

func _ready():
	container.player = player

	container.accept_legs_behaviors()
	container.accept_player_states()
	container.accept_actions()
	container.accept_legs_actions()


	player_sm.initialise()

	accept_modifiers()


func update(input: InputPackage, delta: float):
	player_sm.update(input, delta)
	# legs_sm.update(input, delta)
	

func accept_modifiers():
	var animators := [full_body, torso, legs_animator]
	for a_ in animators:
		a_.current_animation = a_.native_animator.get_animation("idle_longsword")
		a_.current_animation_cycling = a_.current_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR
		a_.current_animation_progress = 0
		a_.previous_animation = a_.native_animator.get_animation("idle_longsword")
		a_.previous_animation_cycling = a_.previous_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR
		a_.previous_animation_progress = 0
		a_.__initialised = true
	meta.__initialised = true


var fly_mode_enabled := false
var fly_speed := 15

func _handle_fly_mode(input: InputPackage, delta: float):
	# var input_direction = (player.camera_mount.basis * Vector3(-input.input_direction.x, 0, -input.input_direction.y)).normalized()
	# todo: this is that strange valocity chain
	var tracking_angular_speed := 4
	var input_direction := __velocity_by_input(input, delta).normalized()
	var face_direction = player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	player.rotate_y(clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))

	# Normalize and scale
	if input_direction != Vector3.ZERO:
		input_direction = input_direction.normalized() * fly_speed

	player.velocity = input_direction
	if input.actions.has(PS.jump_run):
		player.velocity.y += 8
	if input.combat_actions.has(InDataCombatAction.heavy_attack_pressed):
		player.velocity.y -= 8

	
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

func __velocity_by_input(input: InputPackage, delta: float) -> Vector3:
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
