@tool
@icon("res://-assets-/x_icons/white/icon_grid.png")
extends NodeSystem
class_name PHContainer


@onready var leaf_state_pool: Node = %LeafStatePool

var _node_state_container: BaseNodeStateDataContainer


var me: PHCharacter


var _states: Dictionary[String, BasePHEState]


## returns null if no state found
func get_state_by_name(state_name: String) -> BasePHEState:
	if not _states.has(state_name):
		__log_warn(pp.s("_states dict doesn't have ", pp.in_q(state_name)))
		return null
	return _states[state_name]


func accept_states(node_state_container_: BaseNodeStateDataContainer):
	self._node_state_container = node_state_container_
	_accept_states()
	_initialise_states()


func _initialise_states():
	for state: BasePHEState in _states.values():
		state._initialise()


func __accept_base_state(node: BasePHEState, state_data: EDC.BaseStData):
	# specific
	node.state_name = state_data.state_name
	node.fatigue = state_data.commit_data.fatigue
	node.commitment = state_data.commit_data.commitment

	# common
	node.me = me
	node.container = self
	node.anim_container = me.anim_container
	node.phe_feelings = me.phe_feelings
	node.combat = me.get_combat()
	node.animator_manager = me.animator_manager
	node.e_movement = me.get_e_movement()
	node.anim_params_container = me.get_anim_params_container()
	node.config = me.config
	# 	
	print_.e_container("Accepted", pp.s("st name", state_data.state_name))

	# store
	_states[state_data.state_name] = node


func _accept_states():
	## COMPOSITE
	for descendant: get_descendants.Descendant in get_descendants.base_ph_composite_states_with_depth(self):
		var node: BasePHEState = descendant.node_
		print_.e_container("", "node.get_name() " + node.get_name())

		var depth := descendant.depth

		node.state_depth = depth

		assert(node.state_depth <= PHEStaticConfig.MAX_DEPTH, "too much")

		var state_data: EDC._CSData = _node_state_container.get_node_to_composite_state_data().get(node.get_name())
		if not state_data:
			__log_warn(pp.s("EDC._CSData for", node.get_name(), "not found, skipping"))
			continue

		__accept_base_state(node, state_data)

	## LEAF
	for node: BasePHELeaf in get_descendants.base_ph_leaf_states(leaf_state_pool):
		print_.e_container("", "node.get_name() " + node.get_name())

		var lst_data: EDC._LStData = _node_state_container.get_node_to_leaf_state_data().get(node.get_name())
		if not lst_data:
			__log_warn("EDC._LStData for", node.get_name(), "not found, skipping")
			continue

		var _anim := me.anim_container.get_by_anim_id(lst_data.anim_data.anim_id)
		node.anim = _anim
		node.y_offset_adjustment = lst_data.anim_data.y_offset_adjustment

		assert(node.anim and node.anim.anim_id, "node anim problem")

		__accept_base_state(node, lst_data)


## __LOGS
# region


func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# endregion
