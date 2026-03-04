@tool
class_name MechFighterStatesContainer
extends BaseStatesContainer


var _node_state_container: MechFighterNodeStateContainer
var _anim_container: AnimContainer
var _me: MechFighter


var _states: Dictionary[StringName, BaseMechFighterState]


## returns null if no state found
func get_state_by_name(state_name: StringName) -> BaseMechFighterState:
	if not _states.has(state_name):
		__log_warn(pp.s("_states dict doesn't have ", pp.in_q(state_name)))
		return null
	return _states[state_name]


func accept_states(
		node_state_container_: MechFighterNodeStateContainer,
		anim_container_: AnimContainer,
		me_: MechFighter
	):
	self._node_state_container = node_state_container_
	self._anim_container = anim_container_
	self._me = me_
	_accept_states()
	_initialize_states()


func _initialize_states():
	for state: BaseMechFighterState in _states.values():
		state._initialize()


func _accept_states():
	for node: BaseMechFighterState in get_descendants.base_m_f_states(self ):
		__log_("_accept_states", "node.get_name()", node.get_name())

		var st_data: MechFighterNodeStateContainer._StateData = _node_state_container.get_node_to_state_data().get(node.name)
		if not st_data:
			__log_warn(pp.s("no st_data for node", pp.in_q(node.get_name())), "", "skipping")
			continue

		var _anim := _anim_container.get_by_anim_id(st_data.anim_id)
		node.anim = _anim
		node.me = _me

		node.state_name = st_data.state_name
		
		_states[st_data.state_name] = node


## __LOGS
# region


func __LOG_B() -> bool:
	return false

# endregion
