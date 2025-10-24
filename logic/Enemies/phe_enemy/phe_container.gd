@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_grid.png")
extends Node
class_name PHContainer


var me: PHCharacter


class _Data:
	var state_name: String
	## NOTE: In HSM can be empty "" for phases
	var anim_name: String

	func _init(
			state_name_: String,
			anim_name_: String = "",
		) -> void:
		self.state_name = state_name_
		self.anim_name = anim_name_


var node_to_state_data: Dictionary = {
	"_Top": _Data.new(PHEState._TOP),
	"Life": _Data.new(PHEState.life),
	
	"StillLifePhase": _Data.new(PHEState.still_life_phase),
	"Sleep": _Data.new(PHEState.sleep, PHEA.sleep),
	"Awaken": _Data.new(PHEState.awaken, PHEA.awaken),

	"PursuingPhase": _Data.new(PHEState.pursuing_phase),
	"Orbit": _Data.new(PHEState.orbit, PHEA.strafe_right),
	"Pursue": _Data.new(PHEState.pursue, PHEA.walk_forward),
	
	#
	# "Combat_1": _Data.new(PHEState.combat_1, ""),
	# "Scare-off": _Data.new(PHEState.scare_off, PHA.scare_off),
	# "GapClose": _Data.new(PHEState.gapclose, PHA.gapclose_1),
	# "AttackSeries": _Data.new(PHEState.attack_series, ""),
	# "Attack1": _Data.new(PHEState.attack_1, PHA.slash_1),
	# "Attack2": _Data.new(PHEState.attack_2, PHA.slash_2),
	# "Attack3": _Data.new(PHEState.attack_3, PHA.slash_3),
	# "Attack4": _Data.new(PHEState.attack_4, PHA.slash_4),
	# "Attack5": _Data.new(PHEState.attack_5, PHA.slash_5),
	# "Attack6": _Data.new(PHEState.attack_6, PHA.slash_6),
	# "PhaseSwitch": _Data.new(PHEState.phase_switch, PHA.phase_switch),
	# "Phase_2": _Data.new(PHEState.phase_2, ""),
	# "Pursuit_2": _Data.new(PHEState.pursuit, PHA.pursuit_run),
	# "Gapclose": _Data.new(PHEState.gapclose, PHA.gapclose_2),
	# "Kick": _Data.new(PHEState.kick, PHA.kick),
	# "Elbow": _Data.new(PHEState.elbow, PHA.elbow),
	# "Shoulder": _Data.new(PHEState.shoulder_kick, PHA.shoulder_kick_placeholder),
	# "Attack24": _Data.new(PHEState.slash_4, PHA.slash_4),
	# "Attack25": _Data.new(PHEState.slash_5, PHA.slash_5),
	# "Attack7": _Data.new(PHEState.slash_7, PHA.slash_7),
	# "Attack8": _Data.new(PHEState.slash_8, PHA.slash_8),
	# "Death": _Data.new(PHEState.death, PHA.death)
}


var states: Dictionary # { String : BasePHState }


func accept_states():
	for node: BasePHState in get_descendants.base_ph_states(self):
		print_.container("", "node.get_name() " + node.get_name(), 0, LogL.FORCE_PRINT)
		var state_data: _Data = node_to_state_data.get(node.get_name())
		assert(state_data, "_Data for " + node.get_name() + " not found")

		print_.container("", "state_data.state_name " + state_data.state_name, 0, LogL.FORCE_PRINT)

		states[state_data.state_name] = node
		
		# specific
		node.state_name = state_data.state_name
		node.animation = state_data.anim_name
		
		var children = _get_one_level_children(node)
		if children.size() > 0:
			node.is_container = true
			node.current_lower_state = children[0] # default
			print_.container("", "is_container " + str(node.is_container), 0, LogL.FORCE_PRINT)


		# common
		node.me = me
		node.container = self
		node.animator = me.animator
		node.states_data_repo = me.states_data_repo
		node.phe_feelings = me.phe_feelings
		node.weapons = me.weapons
		node.active_weapon = me.active_weapon
		node.combat = me.combat


		# state.animation = state_anims[state.state_name]
		assert(node.state_name and not node.state_name.is_empty(), " state name missing on one of the states " + str(node))


func _get_one_level_children(node: BasePHState) -> Array[BasePHState]:
	var _children: Array[BasePHState] = []
	for child in node.get_children():
		if child is BasePHState:
			var _child_casted: BasePHState = child
			_children.append(_child_casted)
	return _children


func get_state_by_name(state_name: String) -> BasePHState:
	assert(states.has(state_name), "states dict doesn't have " + state_name)
	return states[state_name]
