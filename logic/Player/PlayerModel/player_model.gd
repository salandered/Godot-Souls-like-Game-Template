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
@onready var _begin: BeginModifier = %_Begin
@onready var full_body: SimpleAnimator_ = %FullBody
@onready var torso: SimpleAnimator_ = %Torso
@onready var legs_animator: SimpleAnimator_ = %Legs
@onready var _end: EndModifier = %_End

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var player_sm: PlayerSM = %PlayerSM
@onready var legs_sm: LegsSM = %LegsSM

func _ready():
	container.player = player
	player_sm.player = player
	
	container.accept_legs_behaviors()
	container.accept_player_states()
	container.accept_player_actions()
	container.accept_legs_actions()


	player_sm.initialise()

	accept_modifiers()

	# DEBUG ANIMATIONS
	_reload_run_anims_from_library()


func update(input: InputPackage, delta: float):
	player_sm.update(input, delta)
	player.move_and_slide()
	

func accept_modifiers():
	var animators := [full_body, torso, legs_animator]
	for a_ in animators:
		u.assert_has_animation(a_.native_animator, A.combat_idle)
		a_.current_animation = a_.native_animator.get_animation(A.combat_idle)
		a_.current_animation_cycling = a_.current_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR
		a_.current_animation_progress = 0
		a_.previous_animation = a_.native_animator.get_animation(A.combat_idle)
		a_.previous_animation_cycling = a_.previous_animation.loop_mode == Animation.LoopMode.LOOP_LINEAR
		a_.previous_animation_progress = 0
		a_.__initialised = true
	_begin.__initialised = true
	_end.__initialised = true


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


func _reload_run_anims_from_library() -> void:
	run_anims.clear()
	if animation_player == null:
		return
	var prefix := run_lib + "/"
	for name_ in animation_player.get_animation_list():
		if name_.begins_with(prefix):
			run_anims.append(name_)
	# run_anims.sort() # alphabetical is fine; remove if you prefer original order
	_run_anim_i = clampi(_run_anim_i, 0, max(0, run_anims.size() - 1))

var _run_anim_i: int = 0
var run_lib := "run-v5-LIB"

var run_anims: PackedStringArray = [] # will be filled like ["run-v5-LIB/Running", …]


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dev_fly_mode"):
		__toggle_fly_mode()

	if event.is_action_released("dev_speed_up"):
		fly_speed += 5
	if event.is_action_released("dev_speed_down"):
		fly_speed -= 5


	if event.is_action_pressed("dev_change_run_anim"):
		_run_anim_i = (_run_anim_i + 1) % run_anims.size()
		__apply()
	elif event.is_action_pressed("dev_change_run_anim_prev"):
		_run_anim_i = (_run_anim_i - 1 + run_anims.size()) % run_anims.size()
		__apply()


func __apply() -> void:
	var run_action := container.action_by_name(PS.action_run)
	var l_run_action := container.legs_action_by_name(LS.legs_action_run)
	if run_anims.is_empty():
		return
	var anim_name: String = run_anims[_run_anim_i] # already "run-v5-LIB/Running"
	if animation_player.has_animation(anim_name):
		run_action.animation = anim_name
		run_action.backend_animation = anim_name + "-param"
		l_run_action.animation = anim_name
		print_.prefix(print_.DEBUG, "run anim -> " + anim_name)
	else:
		print_.prefix(print_.DEBUG, "run anim not found -> " + anim_name)


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
