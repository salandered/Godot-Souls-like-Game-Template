@abstract
class_name PHCharacter
extends BaseEnemyCharacter


@export var show_ui_feelings: bool = false
@export var float_ui_feelings: bool = false
@export var record_state_history: bool = false
@export var process_disabled_on_init: bool = true
@export var head_off: bool = true
@export var push_rigid: bool = true
@export var allow_move_and_slide: bool = true


@onready var config: PHEConfig = %Config
@onready var container: PHEContainer = %StatesContainer

@onready var phe_feelings: PHEFeelings = $PHEFeelings
@onready var _top: BasePHEState = %_Top


## anim
@onready var native_player: AnimationPlayer = %NativePlayer


## sfx
@onready var e_anim_sfx_sig_emitter: EnemyAnimSFXSignalEmitter = %EAnimSFXSigEmitter

@onready var ui_feelings: EnemyUIFeelings = %UIFeelings
@onready var ui_marker: Marker3D = %UIMarker

@onready var _start_position := global_transform.origin


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


## TROUBLESHOOTING
## - Root animation are not quite right, visual and enemy node are not synced:
##    => check root_motion_track of NativePlayer!
##       it's very fragile, any change of node tree and it's gone


func get_e_movement() -> EnemyMovement:
	var casted: EnemyMovement = get_movement()
	return casted

func get_animator_manager() -> EnemyAnimatorManager:
	var casted: EnemyAnimatorManager = super.get_animator_manager()
	return casted


func __hard_dependencies() -> Array:
	var ds: Array[Object] = [
		# player,
		config,
		container,
		phe_feelings,
		_top,
		get_visuals_root(),
	]
	return super.__hard_dependencies() + ds

func __soft_dependencies() -> Array:
	var ds: Array[Object] = [
		coll_collider,
		# camera_target,
		e_anim_sfx_sig_emitter,
		]
	return super.__soft_dependencies() + ds


@abstract func initialise_implementation() -> void

@abstract func get_initial_leaf_state_name() -> String

@abstract func get_visuals_root() -> Node3D

@abstract func get_node_state_container() -> PHEBaseNodeStateDataContainer


func initialise_base_char_implementation() -> void:
	super.initialise_base_char_implementation()

	char_type = DevVisualsConfig.CharacterType.HSM_ENEMY

	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Masks.OTHER_CHAR_COL_MASK
	
	if container:
		container.me = self
		container.accept_states(get_node_state_container())

	visuals = get_descendants.mesh_instances(get_visuals_root(), true)
	if ui_feelings:
		ui_feelings.initialise(show_ui_feelings, phe_feelings, ui_marker if float_ui_feelings and ui_marker else null)
	

	initialise_implementation()

	if not __perform_validation():
		__log_warn_soft("PHCharacter failed initalisation")
		process_mode = PROCESS_MODE_DISABLED
	else:
		_initialise_sm()


## cont
func _for_init_sig_container() -> BaseCharacterSignalContainer:
	return EnemySignalContainer.new()
func _for_init_sad_container() -> BaseCharacterSADContainer:
	return EnemySADContainer.new()

## anim
func _for_init_native_player() -> AnimationPlayer:
	return native_player
##
func _for_init_visuals() -> BaseVisuals:
	return null ## todo: use in enemy
func _for_init_bones() -> BaseCharBones:
	return null ## todo: use in enemy

## sfx
func _for_init_asp_config_container() -> BaseCharacterASPConfigContainer:
	return EnemyASPConfigContainer.new()
func _for_init_anim_sfx_sig_emitter() -> BaseAnimSFXSignalEmitter:
	return e_anim_sfx_sig_emitter


func _initialise_sm():
	angry_raised = false
	state_machine = _top

	var _initial_leaf := container.get_state_by_name(get_initial_leaf_state_name())
	_curr_leaf = _initial_leaf
	_prev_leaf = _initial_leaf

	fatigue_raised = false
	state_machine._on_enter_state()
	if process_disabled_on_init:
		set_process(false)


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


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	super._physics_process(delta)
	if u.is_nth_frame(10):
		basis = basis.orthonormalized()

	state_machine._update(delta)

	if allow_move_and_slide:
		move_and_slide()

	if push_rigid:
		PushRigidBodies.push_rigid_bodies_by_char(self , push_rigid_bodies_force)

	# player.__dev_labels._label_phe_enemy_info(self)

	if death_raised:
		_on_death_raised()


func react_on_hit(hit_data: HitData) -> void:
	if not __validation_ok():
		return
	var _curr_state := get_current_state()
	if not _curr_state:
		__log_error("no _curr_state", "react_on_hit", "no hit applied, it's lost", hit_data)
		return
	_curr_state.react_on_hit(hit_data)


func is_invincible() -> bool:
	return false


func reset_position(y_offset: float = 0.0) -> void:
	transform.origin = _start_position
	transform.origin.y += y_offset
	# prints("reset_position", y_offset)


func _on_death_raised() -> void:
	if death_raised_processed:
		return
	
	death_raised_processed = true
	angry_raised = false
	death_raised = false
	
	SIG_death_raised.emit()

	print_.prefix("camera_target.make_inactive()")
	camera_target.make_inactive()


	_on_death_raised_implementation()
	
	await FrameUtils.wait_process_frames(5)
	print_.prefix("coll_collider.disabled = true")

	_shrink_coll_capsule()

	self.collision_layer = Collision.Layers.DEBRIS_COL
	self.collision_mask = Collision.Masks.DEBRIS_COL_MASK
		
	await FrameUtils.wait_process_frames(2)
	self.set_process(false)
	self.set_physics_process(false)
	var _look_at_manager_: ELookAtManager = get_look_at_manager()
	if _look_at_manager_:
		_look_at_manager_.shut_down()
	var _look_at_marker := get_look_at_char_marker()
	if _look_at_marker:
		_look_at_marker.active = false
	# todo: it works but we need proper checks for external systems to be ready for this; also visuals
	# self.queue_free()


func _on_death_raised_implementation():
	pass
	

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


func __pp_state_history():
	return "state history " + pp.array_(_state_history) if record_state_history else "[state history was not recorded]"


##

func get_run_state_names() -> Array[String]:
	return []

func get_dodge_state_names() -> Array[String]:
	return []

func get_sprint_state_names() -> Array[String]:
	return []

func get_idle_state_names() -> Array[String]:
	return []


func get_power_attacks_state_names() -> Array[String]:
	return [
	   ]

##


const AIR_WAVE_2 = preload("uid://cxfgvp3futm7q")


func _on_sig_land_wave(char_glob_position: Vector3, anim: String) -> void:
	if not AIR_WAVE_2:
		return

	var wave := AIR_WAVE_2.instantiate()

	get_tree().current_scene.add_child(wave)

	wave.spawn_shockwave_at_position(char_glob_position, anim)
