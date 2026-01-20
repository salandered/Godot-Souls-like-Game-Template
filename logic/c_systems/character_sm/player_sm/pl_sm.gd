extends NodeCharacterSystem
class_name PlayerSM

@onready var area_awareness: AreaAwareness = %AreaAwareness
@onready var animator_manager: PlAnimatorManager = %AnimatorManager
@onready var legs_sm: LegsSM = %LegsSM

var _player: Princess

@onready var container: PlayerStatesContainer = %StatesContainer


var player_movement: PlayerMovement

var combat: PlayerCombat

var _transfer_data: TranferData = TranferData.new()


## not nullable 
var current_state: BasePlayerState
var prev_state_name: String

var _current_action: BaseAction
var _prev_action: BaseAction

var hit_timer: SimpleTimer = SimpleTimer.new()
var hit_value_influencer: ValueInfluencer = ValueInfluencer.new(0.8, "hit_value_influencer")


func is_player() -> bool:
	return true


func initialise(player: Princess) -> void:
	self._player = player
	self.combat = player.get_combat()
	self.player_movement = player.get_pl_movement()
	var empty_input := InputPackage.new()

	var _idle_action := container.l_action_by_name(Leg.Act.idle)
	var _double_st_action := container.pl_action_by_name(PS.Act.double)
	var _first_state := container.state_by_name(PS.idle)
	var _first_beh := container.l_behavior_by_name(Leg.Beh.idle)
	
	# global level
	current_state = _first_state
	prev_state_name = _first_state.state_name
	_current_action = _idle_action
	_prev_action = _idle_action

	# state level
	current_state.curr_state_action = _double_st_action

	# legs sm level
	legs_sm.current_behavior = _first_beh
	legs_sm._current_action = _idle_action
	legs_sm._prev_action = _idle_action


func get_player() -> Princess:
	return _player


func apply_hit_influence(value: float, target_multiplier: float = -1.0) -> float:
	return hit_value_influencer.influence_value(value, hit_timer, target_multiplier)


# TODO: fast solution. Design proper action (or states) ability to share data.
## for now its supposed to store only prev action data
## so actions can only use these methods for working with tranfer data
func fill_tranfer_data(tranfer_data: Dictionary[String, Variant]):
	## auto setting current action
	_transfer_data.fill(_current_action.action_name, tranfer_data)


## optional return
func get_tranfer_data_by_key(key: String) -> Variant:
	## auto getting prev one
	var data: Variant = _transfer_data.get_by_action_and_key(_prev_action.action_name, key)
	return data


func get_curr_action() -> BaseAction:
	return _current_action


func get_prev_action() -> BaseAction:
	return _prev_action


## returns newly shifted previous action name
func update_current_action(next_action: BaseAction) -> String:
	# var curr_act_name = ""
	# if not _current_action:
		# curr_act_name = "-none-"
		# print_.dev(em.pin, "no _current_action. Should happen only on start up.")
	# else:
	var curr_act_name := _current_action.action_name
		
	var next_act_name := next_action.action_name

	if next_act_name == Leg.Act.double:
		# print_.dev("", "✖️ declined legs double update to curr. staying with " + curr_act_name)
		return _prev_action.action_name
	if next_act_name == PS.Act.double:
		# print_.dev("", "✖️ declined state double update to curr. staying with " + curr_act_name)
		return _prev_action.action_name

	# if next_act_name == curr_act_name:
		# print_.dev(em.pin, "✖️🚸 came with the same action " + curr_act_name)

	# print_.dev("[[]]", pp.s(next_act_name, "is set for curr |",
		# curr_act_name, "moved to prev"), 18)
	
	_prev_action = _current_action
	_current_action = next_action
	# if _prev_action and next_act_name == _prev_action.action_name:
		# print_.dev(em.pin, em.red_x + "new curr equal prev! " + next_act_name)
	
	return _prev_action.action_name


func react_on_hit(hit_data: HitData) -> void:
	if not current_state:
		__log_warn("no _curr_state", "player sm", "no hit applied, it's lost", hit_data)
		return
	hit_timer.initialise(0.4)
	current_state.react_on_hit(hit_data)


func update(input_: InputPackage, delta: float) -> void:
	input_ = combat.contextualize(input_, delta)
	input_ = area_awareness.contextualize(input_)

	hit_timer.update(delta)

	var verdict := current_state._check_transition(input_)
	verdict._speak_freely()

	if verdict.needs_switch():
		print_.psm("", "")
		print_.psm("↪️", current_state.state_name + " => " + verdict.next_state)
		
		current_state._on_exit_state()
		prev_state_name = current_state.state_name
		# now current_state is next state
		current_state = container.state_by_name(verdict.next_state)
		current_state._on_enter_state(input_)


	current_state._update(input_, delta)


## __LOGS
# region

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
