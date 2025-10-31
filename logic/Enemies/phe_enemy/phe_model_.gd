extends BaseEnemyCharacter
class_name PHCharacter


## It's all: SM, Base state, Root state
var state_machine: BasePHEState

@export_group("Container Fields")
@onready var container: PHContainer = $StatesContainer
@onready var combat: PHCombat = %Combat
@onready var enemy_movement: EnemyMovement = %EnemyMovement
@onready var native_player: AnimationPlayer = %NativePlayer
@onready var anim_container: AnimationContainer = $AnimContainer
@onready var animator_manager: EnemyAnimatorManager = %AnimatorManager
@onready var _top: BasePHEState = %_Top
@onready var phe_feelings: PHEFeelings = $PHEFeelings
@onready var active_weapon: PingaBlade = $bones/RightWrist/WeaponSocket/BigPingaBlade


const BREADCRUMB_SIZE = 10
var _state_history: Array[String] = []

# if any state works longer than fatigue, flag is raised. 
# HSME SM than switches to the most safest state
var fatigue_raised: bool = false


var _curr_leaf: BasePHELeaf
var _prev_leaf: BasePHELeaf


## TROUBLESHOOTING
## - Root animation are not quite right, visual and enemy node are not synced:
##    => check root_motion_track of NativePlayer!
##       it's very fragile, any change of node tree and it's gone

func _ready():
	collision_layer = Collision.Layers.OTHER_CHAR_COL
	collision_mask = Collision.Mask.OTHER_CHAR_COL_MASK
	state_machine = _top

	animator_manager.initialise()
	

	var _anim_list := PHEA.new()
	anim_container._accept_animations(_anim_list.list_of_animations, native_player) # NOTE: should be before accepting states!

	enemy_movement.me = self
	container.me = self
	container.accept_states()

	var _sleep_state = container.get_state_by_name(PHEState.Leaf.sleep)
	_curr_leaf = _sleep_state
	_prev_leaf = _sleep_state

	fatigue_raised = false
	# state_machine.current_state = container.get_state_by_name(PHEState.Leaf.awaken)
	state_machine._on_enter_state()


func get_current_state() -> BasePHEState:
	return state_machine.get_current_substate()

func react_on_hit(hit_data: HitData) -> void:
	get_current_state()._react_on_hit(hit_data)


func get_player() -> Princess:
	return player


## returns newly shifted previous leaf state name
func update_curr_leaf_state(next_state: BasePHELeaf) -> String:
	var curr_state_name := _curr_leaf.state_name
	var next_state_name := next_state.state_name

	# if next_state_name == Leg.Act.double:
	# 	# print_.dev("", "✖️ declined legs double update to curr. staying with " + curr_act_name)
	# 	return _prev_leaf.state_name

	if next_state_name == curr_state_name:
		print_.phe_sm(em.pin, "✖️🚸 came with the same state " + curr_state_name)

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


func __pp_state_history():
	return "state history" + pp.in_sq(pp.list_(_state_history))


func _physics_process(delta):
	state_machine._update(delta)
	move_and_slide()


	player.dev_labels._label_phe_enemy_info(self)
