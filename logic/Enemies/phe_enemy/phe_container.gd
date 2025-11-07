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
			commitment_: float = PHEStaticConfig.DEF_COMMITMENT,
			fatigue_: float = PHEStaticConfig.DEF_FATIGUE,
		) -> void:
		self.commitment = commitment_
		self.fatigue = fatigue_


class _AData:
	var anim_id: String
	var y_offset_adjustment: float
	func _init(
			anim_id_: String,
			y_offset_adjustment_: float = PHEStaticConfig.DEFAULT_Y_OFFSET
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
	"_Top": _CSData.new(PHES._TOP, _CommitData.new(-1, -1)),
	"Life": _CSData.new(PHES.life, _CommitData.new(-1, -1)),

	"StillLifePhase": _CSData.new(PHES.still_life_phase, _CommitData.new(-1, -1)),
	"CombatPhase": _CSData.new(PHES.combat_phase, _CommitData.new(-1, -1)),
	"DeathPhase": _CSData.new(PHES.death_phase, _CommitData.new(-1, -1)),
	
	"CombatLoco": _CSData.new(PHES.combat_loco, _CommitData.new(-1, -1)),
	"CombatAttacking": _CSData.new(PHES.combat_attacking),
	"AttackClubSeries": _CSData.new(PHES.attack_club_series),
	"AttackPickSingle": _CSData.new(PHES.attack_pick_single),
	"AttackFromDodgeB": _CSData.new(PHES.attack_from_dodge_b),
	"AttackWithDodgeF": _CSData.new(PHES.attack_with_dodge_f),
	"Attack360Series": _CSData.new(PHES.attack_360_series),
	
	"DodgeBackSeries": _CSData.new(PHES.dodge_back_series),
	"DodgePlayful": _CSData.new(PHES.dodge_playful),
}


var node_to_leaf_state_data: Dictionary = {
	## one time
	"Sleep": _LStData.new(PHES.Leaf.sleep, _AData.new(PHEA.sleep, -0.15), _CommitData.new(-1, -1), ),
	"Awaken": _LStData.new(PHES.Leaf.awaken, _AData.new(PHEA.awaken, -0.15), ),
	"Death": _LStData.new(PHES.Leaf.death, _AData.new(PHEA.death)),
	"PhaseSwitch": _LStData.new(PHES.Leaf.phase_switch, _AData.new(PHEA.phase_switch, -0.3)),

	## loco
	"CombatIdle": _LStData.new(PHES.Leaf.combat_idle, _AData.new(PHEA.loco.combat_idle, -0.03), _CommitData.new(0.4), ),
	"Pursue": _LStData.new(PHES.Leaf.pursue, _AData.new(PHEA.loco.run_forward, -0.06), _CommitData.new(0.3, 30)),
	"Orbit": _LStData.new(PHES.Leaf.orbit, _AData.new(PHEA.loco.strafe_right), _CommitData.new(0.5)),
	"DodgeB": _LStData.new(PHES.Leaf.dodge_B, _AData.new(PHEA.loco.dodge_B, -0.05)),
	"DodgeF": _LStData.new(PHES.Leaf.dodge_F, _AData.new(PHEA.loco.dodge_F, -0.05)),
	"DodgeL": _LStData.new(PHES.Leaf.dodge_L, _AData.new(PHEA.loco.dodge_L, -0.05)),
	"DodgeR": _LStData.new(PHES.Leaf.dodge_R, _AData.new(PHEA.loco.dodge_R, -0.05)),
	"JumpTowards": _LStData.new(PHES.Leaf.jump_towards, _AData.new(PHEA.loco.jump_towards, -0.1)),

	## attack
	"ScareOff": _LStData.new(PHES.Leaf.scare_off, _AData.new(PHEA.attack.scare_off, -0.25)),
	"GapCloser": _LStData.new(PHES.Leaf.gap_closer, _AData.new(PHEA.attack.power_gap_closer, -0.24)),
	"ClubPart1": _LStData.new(PHES.Leaf.club_part_1, _AData.new(PHEA.attack.club_part_1, -0.15)),
	"ClubPart2": _LStData.new(PHES.Leaf.club_part_2, _AData.new(PHEA.attack.club_part_2, -0.15)),
	"ClubPart3_4": _LStData.new(PHES.Leaf.club_part_3_4, _AData.new(PHEA.attack.club_part_3_4, -0.15)),
	"Attack360High": _LStData.new(PHES.Leaf.attack_360_high, _AData.new(PHEA.attack.attack_360_high, -0.15)),
	"Attack360Low": _LStData.new(PHES.Leaf.attack_360_low, _AData.new(PHEA.attack.attack_360_low, -0.15)),
	"AttackUp": _LStData.new(PHES.Leaf.attack_up, _AData.new(PHEA.attack.attack_up, -0.13)),
	"AttackDown": _LStData.new(PHES.Leaf.attack_down, _AData.new(PHEA.attack.attack_down, -0.15)),
	"SwordSlide": _LStData.new(PHES.Leaf.sword_slide, _AData.new(PHEA.attack.sword_slide, -0.25)),

	# "PhaseSwitch": _LStData.new(PHES.phase_switch, PHEA.phase_switch),
}

var _states: Dictionary # { String : BasePHEState }


## returns null if no state found
func get_state_by_name(state_name: String) -> BasePHEState:
	if not _states.has(state_name):
		print_.warn_raw(true, pp.s("_states dict doesn't have ", pp.in_q(state_name)))
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
	node.combat = me.combat
	node.native_player = me.native_player
	node.animator_manager = me.animator_manager
	node.e_movement = me.enemy_movement
	node.anim_params_container = me.anim_params_container
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

		var state_data: _CSData = node_to_composite_state_data.get(node.get_name())
		if not state_data:
			print_.warn_raw(false, pp.s("_CSData for", node.get_name(), "not found, skipping"))
			continue

		__accept_base_state(node, state_data)

	## LEAF
	for node: BasePHELeaf in get_descendants.base_ph_leaf_states(leaf_state_pool):
		print_.e_container("", "node.get_name() " + node.get_name())

		var lst_data: _LStData = node_to_leaf_state_data.get(node.get_name())
		if not lst_data:
			print_.warn_raw(false, "_LStData for", node.get_name(), "not found, skipping")
			continue

		var _anim := me.anim_container.get_by_anim_id(lst_data.anim_data.anim_id)
		node.anim = _anim
		node.y_offset_adjustment = lst_data.anim_data.y_offset_adjustment

		assert(node.anim and node.anim.anim_id, "node anim problem")

		__accept_base_state(node, lst_data)
