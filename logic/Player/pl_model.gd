extends Node
class_name PlayerModel

@onready var _player: Princess = $".."
@onready var skeleton: Skeleton3D = %GeneralSkeleton
@onready var combat: PlayerCombat = $Combat
@onready var feelings: PlayerFeelings = %Feelings
@onready var hitbox: Hitbox_ = %HitBox
@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var container: PlayerStatesContainer = %StatesContainer

@onready var player_sm: PlayerSM = %PlayerSM
@onready var legs_sm: LegsSM = %LegsSM
@onready var bones: PlayerBones = %bones

@onready var native_player: AnimationPlayer = %NativeAnimator
@onready var anim_container: AnimationContainer = %AnimContainer
@onready var animator_manager: PlAnimatorManager = %AnimatorManager

var active_weapon: BaseWeapon

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	container.player = _player
	player_sm._player = _player
	
	var _pl_anim_container := PlAnimList.new()
	anim_container._accept_animations(_pl_anim_container.list_of_animations, native_player) # NOTE: should be before accepting states!
	container.accept_all()
	
	player_sm.initialise()
	animator_manager._accept_modifiers()

	# DEBUG ANIMATIONS
	_reload_run_anims_from_library()
	
	bones.accept_bones()

func update(input_: InputPackage, delta: float):
	if fly_mode_enabled:
		_handle_fly_mode(input_, delta)
		_player.move_and_slide()
		return

	player_sm.update(input_, delta)
	_player.move_and_slide()
	

# region: DEV ONLY

var fly_mode_enabled := false
var fly_speed := 15

var _run_anim_i: int = 0
var run_lib := "run-v5-LIB"

var run_anims: PackedStringArray = [] # will be filled like ["run-v5-LIB/Running", …]


func _handle_fly_mode(input_: InputPackage, delta: float):
	var _tracking_angular_speed := 4
	var input_direction := __fly_velocity_by_input(input_, delta).normalized()
	var face_direction := _player.basis.z
	var angle := face_direction.signed_angle_to(input_direction, Vector3.UP)
	_player.rotate_y(clamp(angle, -_tracking_angular_speed * delta, _tracking_angular_speed * delta))

	# Normalize and scale
	if input_direction != Vector3.ZERO:
		input_direction = input_direction.normalized() * fly_speed

	_player.velocity = input_direction
	if input_.actions.has(PS.dodge):
		_player.velocity.y += 8
	if input_.combat_actions.has(CombatAction.heavy_attack_pressed):
		_player.velocity.y -= 8

	
func __toggle_fly_mode():
	fly_mode_enabled = !fly_mode_enabled
	if fly_mode_enabled:
		_player.velocity = Vector3.ZERO
	print_.dev("*** Fly mode: ", fly_mode_enabled)


func _reload_run_anims_from_library() -> void:
	run_anims.clear()
	if native_player == null:
		return
	var anim_lib := A._lib._run
	for name_ in native_player.get_animation_list():
		if name_.begins_with(anim_lib):
			run_anims.append(name_)
	# run_anims.sort() # alphabetical is fine; remove if you prefer original order
	_run_anim_i = clampi(_run_anim_i, 0, max(0, run_anims.size() - 1))

@onready var visuals: PlayerVisuals = $"../Visuals"
@onready var csg_box_3d_2: CSGBox3D = $"../CSGBox3D2"

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dev_fly_mode"):
		__toggle_fly_mode()

	if event.is_action_released("dev_speed_up"):
		fly_speed += 5
	if event.is_action_released("dev_speed_down"):
		fly_speed -= 5
	
	if event.is_action_released("t8"):
		visuals.visible = not visuals.visible
		csg_box_3d_2.visible = not csg_box_3d_2.visible
	# if event.is_action_pressed("dev_change_run_anim"):
	# 	_run_anim_i = (_run_anim_i + 1) % run_anims.size()
	# 	__apply()
	# elif event.is_action_pressed("dev_change_run_anim_prev"):
	# 	_run_anim_i = (_run_anim_i - 1 + run_anims.size()) % run_anims.size()
	# 	__apply()
	
	if event.is_action_pressed("dev_8"):
		# animator_manager.play_overlay(A.hit_reaction, 0.1)
		animator_manager.set_overlay_anim(A.combat.hit_reaction, 0.12, 0.20, 0.18, 1)
		# animator_manager.play_overlay(A.hit_reaction, 0, -1, 0, 1)
		# animator_manager.play_overlay(A.hit_reaction, 0.2, 0.5, 0.2, 0.8)
	if event.is_action_pressed("dev_9"):
		# player_sm.legs_animator.play_overlay(A.hit_reaction, 0.1)
		animator_manager.set_overlay_anim(A.combat.hit_reaction, 0.2, 0.05, 0.2, 1)
		# animator_manager.play_overlay(A.hit_reaction, 0.4, 1, 0.4, 2)

func __fly_velocity_by_input(input_: InputPackage, delta: float) -> Vector3:
	var _velocity := Vector3.ZERO
	var forward_speed := input_.forward_input


	var orbit_speed := input_.orbit_input

	var grounded_target: Vector3
	grounded_target = _player.fancy_camera.nest.global_position
	grounded_target.y = _player.global_position.y

	if forward_speed != 0.0:
		_velocity -= _player.global_position.direction_to(grounded_target) \
					 * forward_speed * 5

	if orbit_speed != 0.0:
		var d: float = orbit_speed * 5 * delta
		var target_direction := grounded_target - _player.global_position
		var distance_to_target := target_direction.length()
		var alpha := -2.0 * asin(d / (2.0 * distance_to_target))
		var rotated_dir := target_direction.rotated(Vector3.UP, alpha)
		var d_vector := grounded_target - rotated_dir - _player.global_position
		_velocity += d_vector / delta
	return _velocity


# endregion
