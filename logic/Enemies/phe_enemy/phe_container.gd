@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")
extends Node
class_name PHContainer


var me: PHCharacter


class _Data:
	var state_name: String
	## NOTE: In HSM can be empty "" for phases
	var anim_id: String
	var commitment: float
	var fatigue: float

	func _init(
			state_name_: String,
			anim_id_: String = "",
			commitment_: float = 0.4,
			fatigue_: float = 20
		) -> void:
		self.state_name = state_name_
		self.anim_id = anim_id_
		self.commitment = commitment_
		self.fatigue = fatigue_


var node_to_state_data: Dictionary = {
	"_Top": _Data.new(PHEState._TOP, "", -1, -1),
	"Life": _Data.new(PHEState.life, "", -1, -1),
	
	"StillLifePhase": _Data.new(PHEState.still_life_phase, "", -1, -1),
	"Sleep": _Data.new(PHEState.Leaf.sleep, PHEA.unsorted.sleep, -1, -1),
	"Awaken": _Data.new(PHEState.Leaf.awaken, PHEA.unsorted.awaken),

	"PursuingPhase": _Data.new(PHEState.pursuing_phase, "", -1, -1),
	"CombatIdle": _Data.new(PHEState.Leaf.combat_idle, PHEA.loco.combat_idle, 0.6),
	"Orbit": _Data.new(PHEState.Leaf.orbit, PHEA.loco.strafe_right, 1.4),
	"SlowPursue": _Data.new(PHEState.Leaf.slow_pursue, PHEA.loco.walk_forward, 0.8),
	"Pursue": _Data.new(PHEState.Leaf.pursue, PHEA.loco.run_forward, 0.5),
	
	"CombatPhase": _Data.new(PHEState.combat_phase),
	"ScareOff": _Data.new(PHEState.Leaf.scare_off, PHEA.attack.scare_off),
	"GapCloserAttack": _Data.new(PHEState.Leaf.gap_closer_attack, PHEA.attack.gap_closer),
	
	"AttackClubSeries": _Data.new(PHEState.attack_club_series),
	"ClubPart1": _Data.new(PHEState.Leaf.club_part_1, PHEA.attack.club_part_1),
	"ClubPart2": _Data.new(PHEState.Leaf.club_part_2, PHEA.attack.club_part_2),
	"ClubPart3_4": _Data.new(PHEState.Leaf.club_part_3_4, PHEA.attack.club_part_3_4),
	
	"AttackPickSingle": _Data.new(PHEState.attack_pick_single),
	"Attack360High": _Data.new(PHEState.Leaf.attack_360_high, PHEA.attack.attack_360_high),
	"Attack360Low": _Data.new(PHEState.Leaf.attack_360_low, PHEA.attack.attack_360_low),
	"AttackUp": _Data.new(PHEState.Leaf.attack_up, PHEA.attack.attack_up),
	"AttackDown": _Data.new(PHEState.Leaf.attack_down, PHEA.attack.attack_down),
	"FancyAttack": _Data.new(PHEState.Leaf.fancy_attack, PHEA.attack.fancy_attack),
	"Death": _Data.new(PHEState.Leaf.death, PHEA.unsorted.death)
	
	# "PhaseSwitch": _Data.new(PHEState.phase_switch, PHEA.phase_switch),
	# "Phase_2": _Data.new(PHEState.phase_2, ""),
	# "Pursuit_2": _Data.new(PHEState.pursuit, PHEA.pursuit_run),
	# "Gapclose": _Data.new(PHEState.gapclose, PHEA.gapclose_2),
}


var _states: Dictionary # { String : BasePHEState }


func accept_states():
	_accept_states()
	_initialise_state()


func _initialise_state():
	for state: BasePHEState in _states.values():
		state.initialise()

func _accept_states():
	for descendant: get_descendants.Descendant in get_descendants.base_ph_states_with_depth(self):
		var node: BasePHEState = descendant.node_
		var depth := descendant.depth
		node.state_depth = depth

		print_.container("", "node.get_name() " + node.get_name(), 0, LogL.FORCE_PRINT)
		var state_data: _Data = node_to_state_data.get(node.get_name())
		if not state_data:
			print_.warn(pp.s("_Data for", node.get_name(), "not found, skipping"))
			continue


		_states[state_data.state_name] = node
		
		# specific
		node.state_name = state_data.state_name


		node.fatigue = state_data.fatigue
		node.commitment = state_data.commitment
		
		var children = _get_one_level_children(node)
		if children.size() > 0:
			node.is_composite = true

		print_.container("", pp.s("st name", state_data.state_name, "is_composite " + str(node.is_composite)), 0, LogL.FORCE_PRINT)

		
		if not node.is_composite:
			var _anim := me.anim_container.get_by_anim_id(state_data.anim_id)
			node.anim = _anim

		# common
		node.me = me
		node.container = self
		node.native_player = me.native_player
		node.phe_feelings = me.phe_feelings
		node.active_weapon = me.active_weapon
		node.combat = me.combat
		node.e_movement = me.enemy_movement
		node.animator_manager = me.animator_manager
		node.anim_container = me.anim_container


		# state.animation = state_anims[state.state_name]
		assert(node.state_name and not node.state_name.is_empty(), " state name missing on one of the _states " + str(node))


func _get_one_level_children(node: BasePHEState) -> Array[BasePHEState]:
	var _children: Array[BasePHEState] = []
	for child in node.get_children():
		if child is BasePHEState:
			var _child_casted: BasePHEState = child
			_children.append(_child_casted)
	return _children


func get_state_by_name(state_name: String) -> BasePHEState:
	assert(_states.has(state_name), "_states dict doesn't have " + state_name)
	return _states[state_name]
