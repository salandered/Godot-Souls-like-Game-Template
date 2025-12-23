extends BaseEnemyCharacter
class_name PHCharacter


@export var show_ui_feelings: bool = false
@export var float_ui_feelings: bool = false

@onready var config: PHEConfig = %Config
@onready var container: PHContainer = %StatesContainer
@onready var enemy_movement: EnemyMovement = %EnemyMovement

@onready var phe_feelings: PHEFeelings = $PHEFeelings
@onready var _top: BasePHEState = %_Top
@onready var visuals_root: Node3D = $"VisualOffset/Visuals/gold parts v2"


## anim
@onready var native_player: AnimationPlayer = %NativePlayer
@onready var anim_container: AnimContainer = %AnimContainer
@onready var animator_manager: EnemyAnimatorManager = %AnimatorManager
@onready var anim_params_container: EAnimParamsContainer = %AnimParamsContainer


## sfx
@onready var sfx_system: EnemySFXSystem = %AudioSystem
@onready var e_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %EAnimSFXSigEmitter
@onready var pinga_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %PingaAnimSFXSigEmitter
@onready var aura_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %AuraAnimSFXSigEmitter

@onready var ui_feelings: EnemyUIFeelings = %UIFeelings

@onready var fire_marker: Marker3D = %fire_marker

@onready var ui_marker: Marker3D = %UIMarker

@onready var _start_position := global_transform.origin
const FLICKER_FIRE = preload("uid://fbyv2s2mo6cx")

## It's all: SM, Base state, Root state
var state_machine: BasePHEState

const BREADCRUMB_SIZE = 10
var _state_history: Array[String] = []

# TODO: some system for flags. (or alternative with events)
# if any state works longer than fatigue, flag is raised. 
# HSME SM than switches to the most safest state
var fatigue_raised: bool = false
var angry_raised: bool = false
var death_raised: bool = false
var death_raised_processed: bool = false
var visuals: Array[MeshInstance3D]


var _curr_leaf: BasePHELeaf
var _prev_leaf: BasePHELeaf

var push_rigid_bodies_force: float = 8.0

signal SIG_angry_raised
signal SIG_death_raised
signal SIG_awaken

@onready var air_wave: AirWave2 = %AirWave

## TROUBLESHOOTING
## - Root animation are not quite right, visual and enemy node are not synced:
##    => check root_motion_track of NativePlayer!
##       it's very fragile, any change of node tree and it's gone

func get_hard_dependencies() -> Array[Object]:
	return [
		player,
		config,
		container,
		enemy_movement,
		anim_container,
		animator_manager,
		get_sig_container(),
		get_combat(),
		phe_feelings,
		_top,
		visuals_root,
	]

func get_soft_dependencies() -> Array[Object]:
	return [
		coll_collider,
		# camera_target,
		sfx_system,
		e_anim_sfx_sig_emitter,
		pinga_anim_sfx_sig_emitter,
		aura_anim_sfx_sig_emitter
		]


func initialise() -> void:
	_initialise_cam_targets()
	_initialise_coll_collder()

	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Masks.OTHER_CHAR_COL_MASK
	
	if config:
		config.me = self

	if container:
		container.me = self
		container.accept_states()

	visuals = get_descendants.mesh_instances(visuals_root, true)
	if ui_feelings:
		ui_feelings.initialise(show_ui_feelings, phe_feelings, ui_marker if float_ui_feelings and ui_marker else null)
	
	if not __validate_deps_set_init():
		__log_warn_soft("PHCharacter failed initalisation")
		process_mode = PROCESS_MODE_DISABLED
	else:
		_initialise_sm()


## cont
func _for_init_sig_container() -> BaseCharacterSignalContainer:
	return EnemySignalContainer.new()
func _for_init_sad_container() -> BaseCharacterSADContainer:
	return EnemySADContainer.new()
## anim cont
func _for_init_anim_container() -> AnimContainer:
	return anim_container
func _for_init_anim_params_container() -> BaseAnimParamsContainer:
	return anim_params_container
func _for_init_anim_list() -> BaseCharAnimList:
	return PHEA.new()
func _for_init_required_markers() -> Dictionary[String, Array]:
	return ERequiredMarkers.anim_to_required_marker
## anim
func _for_init_native_player() -> AnimationPlayer:
	return native_player
func _for_init_anim_manager() -> BaseAnimatorManager:
	return animator_manager
##
func _for_init_visuals() -> BaseVisuals:
	return null ## todo: use in enemy
func _for_init_bones() -> BaseCharBones:
	return null ## todo: use in enemy
func _for_init_movement() -> BaseCharacterMovement:
	return enemy_movement
func _for_init_active_weapon_id_list() -> Array[String]:
	return [WeaponID.big_pinga_blade, WeaponID.bg_aura_weapon]
## sfx
func _for_init_sfx_system() -> CharacterSFXSystem:
	return sfx_system
func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer:
	return EnemyASPConfigContainer.new()
func _for_init_anim_sfx_sig_emitter() -> BaseAnimSFXSignalEmitter:
	return e_anim_sfx_sig_emitter
func _for_init_weapon_id_to_emitter() -> Dictionary[String, BaseAnimSFXSignalEmitter]:
	return {
			WeaponID.big_pinga_blade: pinga_anim_sfx_sig_emitter,
			WeaponID.bg_aura_weapon: aura_anim_sfx_sig_emitter
		}


func _initialise_sm():
	state_machine = _top

	var _sleep_state := container.get_state_by_name(PHES.Leaf.sleep)
	_curr_leaf = _sleep_state
	_prev_leaf = _sleep_state

	fatigue_raised = false
	angry_raised = false
	state_machine._on_enter_state()


func get_current_state() -> BasePHEState:
	## todo: shoud we just return _curr_leaf?
	return state_machine.get_current_substate()

func get_prev_state_name() -> String:
	return _prev_leaf.state_name


func get_player() -> Princess:
	return player


## returns newly shifted previous leaf state name
func update_curr_leaf_state(next_state: BasePHELeaf) -> String:
	var curr_state_name := _curr_leaf.state_name
	var next_state_name := next_state.state_name

	# if next_state_name == curr_state_name:
		# print_.phe_sm(em.pin, "✖️🚸 came with the same state " + curr_state_name)

	# print_.dev("[[]]", pp.s(next_act_name, "is set for curr |",
		# curr_act_name, "moved to prev"), 18)
	
	_prev_leaf = _curr_leaf
	_curr_leaf = next_state
	
	return _prev_leaf.state_name


func get_curr_leaf_state() -> BasePHELeaf:
	return _curr_leaf


func update_state_history(state_name_: String):
	_state_history.append(state_name_)
	if _state_history.size() > BREADCRUMB_SIZE:
		_state_history.pop_front()


func _process(delta: float) -> void:
	if u.is_nth_frame(10):
		basis = basis.orthonormalized()


	state_machine._update(delta)
	move_and_slide()
	PushRigidBodies.push_rigid_bodies(self, push_rigid_bodies_force)

	# player.__dev_labels._label_phe_enemy_info(self)

	if death_raised:
		_on_death_raised()


func react_on_hit(hit_data: HitData) -> void:
	if __could_not_initialised():
		return
	var _curr_state := get_current_state()
	if not _curr_state:
		__log_error("no _curr_state", "react_on_hit", "no hit applied, it's lost", hit_data)
		return
	_curr_state.react_on_hit(hit_data)


func reset_position() -> void:
	transform.origin = _start_position

func apply_fire_to_head():
	if not FLICKER_FIRE or not fire_marker:
		return
	var fire_scene = FLICKER_FIRE.instantiate()
	fire_marker.add_child(fire_scene)
	# fire.position = Vector3.ZERO  # Centered on marker

func remove_fire_effect():
	if not fire_marker:
		return
	for child in fire_marker.get_children():
		child.queue_free()

func set_angry_raised():
	angry_raised = true
	SIG_angry_raised.emit()
	apply_fire_to_head()
	

func _on_death_raised() -> void:
	angry_raised = false
	SIG_death_raised.emit()
	if death_raised_processed:
		return
	
	death_raised_processed = true
	
	print_.prefix("camera_target.make_inactive()")
	camera_target.make_inactive()
	await FrameUtils.wait_process_frames(2)
	
	print_.prefix("_trigger_death_scatter()")
	await _trigger_death_scatter(visuals)


	remove_fire_effect()
	var sig_data := get_sig_container().get_by_sig_id(SignalID.sfx_unique)
	u.safe_emit(sig_data, {SFXConstants.unique_key: SFXConstants.Unique.accomplish})

	await FrameUtils.wait_process_frames(5)
	print_.prefix("coll_collider.disabled = true")


	_shrink_coll_capsule()

	self.collision_layer = Collision.Layers.DEBRIS_COL
	self.collision_mask = Collision.Masks.DEBRIS_COL_MASK
	
	await FrameUtils.wait_process_frames(2)
	
	# todo: it works but we need proper checks for external systems to be ready for this; also visuals
	# self.queue_free()

	
func _shrink_coll_capsule():
	if not coll_collider.shape is CapsuleShape3D:
		__log_error("if not coll_collider.shape is CapsuleShape3D", "", "return")
		return
	var capsule_shape: CapsuleShape3D = coll_collider.shape
	var _orig_height := capsule_shape.height
	var _height_mult := 0.1
	var _desired_height := _orig_height * _height_mult

	# Calculate offset to keep bottom at same Y
	# Bottom moves up by half the height reduction, so compensate
	var height_reduction := _orig_height - _desired_height
	var offset_down := height_reduction / 2.0

	coll_collider.position.y -= offset_down # Move DOWN (negative Y)
	CollShapeTranform.shrink_coll_shape_capsule_size(coll_collider, 1.0, _height_mult)


const RIGID_SHATTER_SCRIPT = preload("uid://cvdt0we2m7pch")

func _trigger_death_scatter(mesh_list: Array[MeshInstance3D]):
	print_.prefix_s("glob position of an enemy", self.global_position)
	var rigids_container := Node3D.new()
	rigids_container.name = "EnemyDebrisContainer"
	get_tree().current_scene.add_child(rigids_container)

	rigids_container.global_position = self.global_position
	
	for visual_mesh: MeshInstance3D in mesh_list:
		if not visual_mesh.mesh:
			continue
		await FrameUtils.wait_one_physics_frame()
		var physics_config := RigidBodyCreator.PhysicsConfig.new(3.0, 1.5, 0.0, 2.5)
		var rigid_body := RigidBodyCreator.create_rigid_body_from_mesh_instance(visual_mesh, physics_config, true)
		if rigid_body:
			rigids_container.add_child(rigid_body)
			rigid_body.global_transform = visual_mesh.global_transform
			rigid_body.set_script(RIGID_SHATTER_SCRIPT)
			rigid_body._ready()
			var backward := -self.transform.basis.z
			var direction := (Vector3.UP * 0.94 + backward * 0.44).normalized()
			var impulse_strength := randf_range(8.0, 9.0)
			rigid_body.apply_central_impulse(direction * impulse_strength)
	
	for visual_mesh: MeshInstance3D in mesh_list:
		visual_mesh.visible = false
	print_.prefix("end of _trigger_death_scatter")


func __pp_state_history():
	return "state history" + pp.array_(_state_history)


##

func get_run_state_names() -> Array[String]:
	return [PHES.Leaf.orbit]

func get_dodge_state_names() -> Array[String]:
	return [PHES.Leaf.dodge_F, PHES.Leaf.dodge_B, PHES.Leaf.dodge_L, PHES.Leaf.dodge_R]

func get_sprint_state_names() -> Array[String]:
	return [PHES.Leaf.pursue]

func get_idle_state_names() -> Array[String]:
	return [PHES.Leaf.combat_idle]


func get_power_attacks_state_names() -> Array[String]:
	return [
		PHES.Leaf.scare_off,
		PHES.Leaf.gap_closer,
		PHES.Leaf.sword_slide,
		PHES.Leaf.power_up,
		PHES.Leaf.attack_360_low,
		PHES.Leaf.phase_switch,
	   ]


## DEV


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	var bone_mask := BoneMask.get_upper_body()
	if event.is_action_pressed(RawAction.DEV_8):
		animator_manager.set_overlay_anim(PHEA.react.react_from_R,
		OverlayConfig.new(
			OverlayConfig.Weight.new(0.5),
			BlendConfig.new(0.12, 0.18),
			1.0,
			bone_mask
			))
	if event.is_action_pressed(RawAction.DEV_9):
		animator_manager.set_overlay_anim(PHEA.react.react_from_R,
		OverlayConfig.new(
			OverlayConfig.Weight.new(1.0),
			BlendConfig.new(0.2, 0.2),
			1.0,
			bone_mask
		))


func _on_sig_land_wave(char_glob_position: Vector3, anim: String) -> void:
	air_wave.spawn_shockwave(anim)
