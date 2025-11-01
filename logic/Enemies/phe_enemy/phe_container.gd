@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")
extends Node
class_name PHContainer

@onready var leaf_state_pool: Node = %LeafStatePool

var me: PHCharacter

class _CommitData:
	var commitment: float
	var fatigue: float
	func _init(
			commitment_: float = PHEConfig.DEF_COMMITMENT,
			fatigue_: float = PHEConfig.DEF_FATIGUE,
		) -> void:
		self.commitment = commitment_
		self.fatigue = fatigue_


class _AData:
	var anim_id: String
	var y_offset_adjustment: float
	func _init(
			anim_id_: String,
			y_offset_adjustment_: float = PHEConfig.DEFAULT_Y_OFFSET
		) -> void:
		self.anim_id = anim_id_
		self.y_offset_adjustment = y_offset_adjustment_


class BaseStData:
	var state_name: String
	var dur_data: _CommitData

	func _init(
			state_name_: String,
			dur_data_: _CommitData = null,
		) -> void:
		self.state_name = state_name_

		if not dur_data_:
			dur_data_ = _CommitData.new()
		self.dur_data = dur_data_


class _CSData extends BaseStData:
	pass


class _LStData extends BaseStData:
	var anim_data: _AData

	func _init(
			leaf_state_name_: String,
			anim_data_: _AData,
			dur_data_: _CommitData = null,
		) -> void:
		super (leaf_state_name_, dur_data_)
		
		self.anim_data = anim_data_


var node_to_composite_state_data: Dictionary = {
	"_Top": _CSData.new(PHEState._TOP, _CommitData.new(-1, -1)),
	"Life": _CSData.new(PHEState.life, _CommitData.new(-1, -1)),

	"StillLifePhase": _CSData.new(PHEState.still_life_phase, _CommitData.new(-1, -1)),
	"CombatLoco": _CSData.new(PHEState.combat_loco, _CommitData.new(-1, -1)),
	"CombatAttacking": _CSData.new(PHEState.combat_attacking),
	"AttackClubSeries": _CSData.new(PHEState.attack_club_series),
	"AttackPickSingle": _CSData.new(PHEState.attack_pick_single),
	"AttackFromDodgeSeries": _CSData.new(PHEState.attack_from_dodge_series),
	"Attack360Series": _CSData.new(PHEState.attack_360_series),
	
	"DodgeSeries": _CSData.new(PHEState.dodge_series),
}


var node_to_leaf_state_data: Dictionary = {
	"Sleep": _LStData.new(PHEState.Leaf.sleep, _AData.new(PHEA.sleep), _CommitData.new(-1, -1), ),
	"Awaken": _LStData.new(PHEState.Leaf.awaken, _AData.new(PHEA.awaken), ),
	"Death": _LStData.new(PHEState.Leaf.death, _AData.new(PHEA.death)),

	## loco
	"CombatIdle": _LStData.new(PHEState.Leaf.combat_idle, _AData.new(PHEA.loco.combat_idle, 0.0), _CommitData.new(0.4), ),
	"Orbit": _LStData.new(PHEState.Leaf.orbit, _AData.new(PHEA.loco.strafe_right), _CommitData.new(0.5)),
	"SlowPursue": _LStData.new(PHEState.Leaf.slow_pursue, _AData.new(PHEA.loco.walk_forward), _CommitData.new(0.4), ),
	"Pursue": _LStData.new(PHEState.Leaf.pursue, _AData.new(PHEA.loco.run_forward), _CommitData.new(0.4), ),
	"Dodge": _LStData.new(PHEState.Leaf.dodge, _AData.new(PHEA.loco.dodge_b)),
	"JumpTowards": _LStData.new(PHEState.Leaf.jump_towards, _AData.new(PHEA.loco.jump_towards)),

	## attack
	"ScareOff": _LStData.new(PHEState.Leaf.scare_off, _AData.new(PHEA.attack.scare_off)),
	"GapCloserAttack": _LStData.new(PHEState.Leaf.gap_closer_attack, _AData.new(PHEA.attack.gap_closer)),
	"ClubPart1": _LStData.new(PHEState.Leaf.club_part_1, _AData.new(PHEA.attack.club_part_1)),
	"ClubPart2": _LStData.new(PHEState.Leaf.club_part_2, _AData.new(PHEA.attack.club_part_2)),
	"ClubPart3_4": _LStData.new(PHEState.Leaf.club_part_3_4, _AData.new(PHEA.attack.club_part_3_4)),
	"Attack360High": _LStData.new(PHEState.Leaf.attack_360_high, _AData.new(PHEA.attack.attack_360_high)),
	"Attack360Low": _LStData.new(PHEState.Leaf.attack_360_low, _AData.new(PHEA.attack.attack_360_low)),
	"AttackUp": _LStData.new(PHEState.Leaf.attack_up, _AData.new(PHEA.attack.attack_up)),
	"AttackDown": _LStData.new(PHEState.Leaf.attack_down, _AData.new(PHEA.attack.attack_down)),
	"FancyGapCloser": _LStData.new(PHEState.Leaf.fancy_gap_closer, _AData.new(PHEA.attack.fancy_gap_closer)),
	"SwordSlide": _LStData.new(PHEState.Leaf.sword_slide, _AData.new(PHEA.attack.sword_slide)),

	# "PhaseSwitch": _LStData.new(PHEState.phase_switch, PHEA.phase_switch),
}

var _states: Dictionary # { String : BasePHEState }


## returns null if no state found
func get_state_by_name(state_name: String) -> BasePHEState:
	if not _states.has(state_name):
		print_.warn(pp.s("_states dict doesn't have ", state_name), true)
		return null
	return _states[state_name]


func accept_states():
	_accept_states()
	_initialise_states()


func _initialise_states():
	for state: BasePHEState in _states.values():
		state._initialise()


func __accept_base_state(node: BasePHEState, state_data: BaseStData):
	# specific
	node.state_name = state_data.state_name
	node.fatigue = state_data.dur_data.fatigue
	node.commitment = state_data.dur_data.commitment

	# common
	node.me = me
	node.container = self
	node.anim_container = me.anim_container
	node.phe_feelings = me.phe_feelings
	node.active_weapon = me.active_weapon
	node.combat = me.combat
	node.native_player = me.native_player
	node.animator_manager = me.animator_manager
	node.e_movement = me.enemy_movement
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

		assert(node.state_depth <= PHEConfig.MAX_DEPTH, "too much")

		var state_data: _CSData = node_to_composite_state_data.get(node.get_name())
		if not state_data:
			print_.warn(pp.s("_CSData for", node.get_name(), "not found, skipping"))
			continue

		__accept_base_state(node, state_data)

	## LEAF
	for node: BasePHELeaf in get_descendants.base_ph_leaf_states(leaf_state_pool):
		print_.e_container("", "node.get_name() " + node.get_name())

		var lst_data: _LStData = node_to_leaf_state_data.get(node.get_name())
		if not lst_data:
			print_.warn(pp.s("_LStData for", node.get_name(), "not found, skipping"))
			continue

		var _anim := me.anim_container.get_by_anim_id(lst_data.anim_data.anim_id)
		node.anim = _anim
		node.y_offset_adjustment = lst_data.anim_data.y_offset_adjustment

		assert(node.anim and node.anim.anim_id, "node anim problem")

		__accept_base_state(node, lst_data)
