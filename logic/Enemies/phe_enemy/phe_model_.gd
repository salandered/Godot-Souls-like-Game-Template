extends BaseEnemyCharacter
class_name PHCharacter


@onready var config: PHEConfig = %Config
@onready var container: PHContainer = %StatesContainer
@onready var enemy_movement: EnemyMovement = %EnemyMovement
@onready var native_player: AnimationPlayer = %NativePlayer
@onready var anim_container: AnimationContainer = %AnimContainer
@onready var animator_manager: EnemyAnimatorManager = %AnimatorManager
@onready var anim_params_container: EAnimParamsContainer = %AnimParamsContainer
@onready var phe_feelings: PHEFeelings = $PHEFeelings
@onready var combat: PHECombat = %Combat
@onready var coll_collider: CollisionShape3D = %CollCollider
@onready var _top: BasePHEState = %_Top
@onready var visuals_root: Node3D = $"VisualOffset/Visuals/gold parts v2"
@onready var camera_target: CameraTarget = %CameraTarget


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

## TROUBLESHOOTING
## - Root animation are not quite right, visual and enemy node are not synced:
##    => check root_motion_track of NativePlayer!
##       it's very fragile, any change of node tree and it's gone

func initialise() -> void:
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Masks.OTHER_CHAR_COL_MASK
	state_machine = _top

	combat.initialise()
	animator_manager.initialise()

	var _anim_list := PHEA.new()
	anim_container._accept_animations(
		_anim_list.list_of_animations,
		native_player,
		EAnimParamsContainer.TRACK_PREFIXES,
		EAnimParamsContainer.get_all_params(),
		ERequiredMarkers.anim_to_required_marker) # NOTE: should be before accepting states!
	
	config.me = self
	enemy_movement.me = self
	container.me = self
	
	container.accept_states()

	visuals = get_descendants.mesh_instances(visuals_root, true)

	var _sleep_state := container.get_state_by_name(PHES.Leaf.sleep)
	_curr_leaf = _sleep_state
	_prev_leaf = _sleep_state

	fatigue_raised = false
	angry_raised = false
	state_machine._on_enter_state()


func pretty_name() -> String:
	return "Enemy"

func get_current_state() -> BasePHEState:
	## returns curr substate of the top state
	return state_machine.get_current_substate()


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


func update_state_history(state_name_):
	_state_history.append(state_name_)
	if _state_history.size() > BREADCRUMB_SIZE:
		_state_history.pop_front()


func _process(delta):
	if not death_raised:
		state_machine._update(delta)
		move_and_slide()
		PushRigidBodies.push_rigid_bodies(self, push_rigid_bodies_force)

		player.__dev_labels._label_phe_enemy_info(self)
	else:
		on_death_raised()

func react_on_hit(hit_data: HitData) -> void:
	var _curr_state = get_current_state()
	if not _curr_state:
		print_.warn(false, "no _curr_state", "react_on_hit", "no hit applied, it's lost", hit_data)
		return
	_curr_state.react_on_hit(hit_data)


func reset_position() -> void:
	transform.origin = _start_position


func on_death_raised() -> void:
	if death_raised_processed:
		return
	
	coll_collider.disabled = true
	death_raised_processed = true

	trigger_death_scatter(visuals)

	# todo: it works but need proper checks for external systems to be ready for this
	# self.queue_free()


func trigger_death_scatter(mesh_list: Array[MeshInstance3D]):
	var rigids_container = Node3D.new()
	rigids_container.name = "EnemyDebrisContainer"
	get_tree().current_scene.add_child(rigids_container)

	rigids_container.global_position = self.global_position
	for visual_mesh: MeshInstance3D in mesh_list:
		if not visual_mesh.mesh: continue
		
		# RIGIDBODY
		var rigid_body = RigidBody3D.new()
		rigids_container.add_child(rigid_body)
		
		# match position/rotation/scale 
		# note: physics engines dislike scaled RigidBodies
		rigid_body.global_transform = visual_mesh.global_transform
		
		# DUPLICATE VISUALS
		var new_mesh = visual_mesh.duplicate()
		rigid_body.add_child(new_mesh)
		
		# Reset transform because RB already holds the world position
		new_mesh.transform = Transform3D.IDENTITY
		# Detach from skeleton so it doesn't try to animate/deform
		# new_mesh.skeleton = NodePath("")
		
		# COLLISIONS
		var _convex_shape = visual_mesh.mesh.create_convex_shape(false)
		var coll_node = CollisionShape3D.new()
		coll_node.shape = _convex_shape
		rigid_body.add_child(coll_node)
		
		#
		visual_mesh.visible = false

	prints("end of trigger_death_scatter")


func __pp_state_history():
	return "state history" + pp.in_sq(pp.list_(_state_history))


## DEV


func _input(event: InputEvent) -> void:
	var bone_mask = BoneMask.get_upper_body()
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
