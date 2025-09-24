@tool
@icon("res://-assets-/x_misc/x_icons/icon_grid.png")

extends Node
class_name HSMStatesContainer


var me: HSMECharacter

var node_to_state_data: Dictionary = {
	"RootHSMState": HSMEStateData.new(HSMEState.ROOT, "", ""),
	"Idle": HSMEStateData.new(HSMEState.idle, HSMEA.idle, ""),
	"Awakening": HSMEStateData.new(HSMEState.awakening, HSMEA.awakening, ""),
	"Life": HSMEStateData.new(HSMEState.life, "", ""),
	"Phase_1": HSMEStateData.new(HSMEState.phase_1, "", ""),
	"Chill_1": HSMEStateData.new(HSMEState.chill_1, "", ""),
	"Orbiting": HSMEStateData.new(HSMEState.orbiting, "", ""),
	"Pursuit_1": HSMEStateData.new(HSMEState.pursuit_1, HSMEA.walk_forward, ""),
	"Combat_1": HSMEStateData.new(HSMEState.combat_1, "", ""),
	"Scare-off": HSMEStateData.new(HSMEState.scare_off, HSMEA.scare_off, ""),
	"GapClose": HSMEStateData.new(HSMEState.gapclose, HSMEA.gapclose_1, ""),
	"AttackSeries": HSMEStateData.new(HSMEState.attack_series, "", ""),
	"Attack1": HSMEStateData.new(HSMEState.attack_1, HSMEA.slash_1, ""),
	"Attack2": HSMEStateData.new(HSMEState.attack_2, HSMEA.slash_2, ""),
	"Attack3": HSMEStateData.new(HSMEState.attack_3, HSMEA.slash_3, ""),
	"Attack4": HSMEStateData.new(HSMEState.attack_4, HSMEA.slash_4, ""),
	"Attack5": HSMEStateData.new(HSMEState.attack_5, HSMEA.slash_5, ""),
	"Attack6": HSMEStateData.new(HSMEState.attack_6, HSMEA.slash_6, ""),
	"PhaseSwitch": HSMEStateData.new(HSMEState.phase_switch, HSMEA.phase_switch, ""),
	"Phase_2": HSMEStateData.new(HSMEState.phase_2, "", ""),
	"Pursuit_2": HSMEStateData.new(HSMEState.pursuit, HSMEA.pursuit_run, ""),
	"Gapclose": HSMEStateData.new(HSMEState.gapclose, HSMEA.gapclose_2, ""),
	"Kick": HSMEStateData.new(HSMEState.kick, HSMEA.kick, ""),
	"Elbow": HSMEStateData.new(HSMEState.elbow, HSMEA.elbow, ""),
	"Shoulder": HSMEStateData.new(HSMEState.shoulder_kick, HSMEA.shoulder_kick_placeholder, ""),
	"Attack24": HSMEStateData.new(HSMEState.slash_4, HSMEA.slash_4, ""),
	"Attack25": HSMEStateData.new(HSMEState.slash_5, HSMEA.slash_5, ""),
	"Attack7": HSMEStateData.new(HSMEState.slash_7, HSMEA.slash_7, ""),
	"Attack8": HSMEStateData.new(HSMEState.slash_8, HSMEA.slash_8, ""),
	"Death": HSMEStateData.new(HSMEState.death, HSMEA.death, "")
}


var states: Dictionary # { String : BaseHSMEState }


func accept_states():
	for node: BaseHSMEState in get_descendants.base_hsme_states(self):
		print_.container("", "node.get_name() " + node.get_name(), 0, L.FORCE_PRINT)
		var state_data: HSMEStateData = node_to_state_data.get(node.get_name())
		assert(state_data, "HSMEStateData for " + node.get_name() + " not found")

		print_.container("", "state_data.state_name " + state_data.state_name, 0, L.FORCE_PRINT)

		states[state_data.state_name] = node
		
		# assigning only state specific data
		node.state_name = state_data.state_name
		node.animation = state_data.animation_name
		node.backend_animation = state_data.backend_animation_name
		
		if _has_state_child(node):
			node.is_container = true
		print_.container("", "is_container " + str(node.is_container), 0, L.FORCE_PRINT)

		# common
		node.me = me
		node.container = self
		node.animator = me.animator
		node.player = me.player
		node.states_data_repo = me.states_data_repo
		node.resources = me.resources
		node.weapons = me.weapons


		# state.animation = state_anims[state.state_name]
		assert(node.state_name and not node.state_name.is_empty(), " state name missing on one of the states " + str(node))


func _has_state_child(node: BaseHSMEState) -> bool:
	for child in node.get_children():
		if child is BaseHSMEState:
			return true
	return false # state is leaf

func get_state_by_name(state_name: String) -> BaseHSMEState:
	assert(states.has(state_name), "states dict doesn't have " + state_name)
	return states[state_name]
