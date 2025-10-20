extends RefCounted
class_name StatesContainer


class StateData:
	var state_name: String
	var priority: int
	var legs_behavior_name: String
	var depends_on_legs: bool

	func _init(
			state_name_: String,
			priority_: int,
			legs_behavior_name_: String = Leg.Beh.double,
			depends_on_legs_: bool = false
		) -> void:
		state_name = state_name_
		priority = priority_
		legs_behavior_name = legs_behavior_name_
		depends_on_legs = depends_on_legs_


class ActionData:
	var state_name: String
	var action_name: String
	var anim_id: String

	func _init(
			state_name_: String,
			action_name_: String,
			anim_id_: String,
		) -> void:
		state_name = state_name_
		action_name = action_name_
		anim_id = anim_id_


var node_to_pl_state_data: Dictionary = { # { Node name : StateData }
	# move
	# "Walk": StateData.new(PS.walk, 2),
	# TODO: seems like depends_on_legs_ true equals to having not legs_double_beh default
	"Idle": StateData.new(PS.idle, 1, Leg.Beh.idle, true),
	"Run": StateData.new(PS.run, 2, Leg.Beh.run, true),
	"Strafe": StateData.new(PS.strafe, 2, Leg.Beh.strafe, true),
	"Sprint": StateData.new(PS.sprint, 3, Leg.Beh.sprint, true),
	
	"Dodge": StateData.new(PS.dodge, 10),
	
	# "SmallJumpRun": StateData.new(PS.small_jump_run, 10),
	"JumpSprint": StateData.new(PS.jump_sprint, 10),
	"Midair": StateData.new(PS.midair, 10),
	"LandingSprint": StateData.new(PS.landing_sprint, 10),
	"Roll": StateData.new(PS.roll, 20),
	"Death": StateData.new(PS.death, 200),
	
	## Attacks
	"Longsword1": StateData.new(PS.longsword_1, 15),
	"Longsword2": StateData.new(PS.longsword_2, 15),
	"AxeSlice1": StateData.new(PS.axe_slice_1, 15),
	"AxeSlice2": StateData.new(PS.axe_slice_2, 15),
	"AttackFromRun": StateData.new(PS.attack_from_run, 15),


	"Staggered": StateData.new(PS.staggered, 100),
	"Parry": StateData.new(PS.parry, 20),
	"Parried": StateData.new(PS.parried, 100),
	"Riposte": StateData.new(PS.riposte, 25),
}


## PLAYER ACTIONS

var node_to_pl_action: Dictionary = { # { Node name : ActionData }
	"_DoubleAction": ActionData.new(PS.for_double, PS.Act.double, A.fake_anim),
	"DodgeAction": ActionData.new(PS.dodge, PS.Act.dodge, A.dodge.dodge_R),

	## attacks
	"AxeSlice1Action": ActionData.new(PS.axe_slice_1, PS.Act.axe_slice_1, A.attack.axe_slice_1),
	"AxeSlice2Action": ActionData.new(PS.axe_slice_2, PS.Act.axe_slice_2, A.attack.axe_slice_2),
	"AttackFromRunAction": ActionData.new(PS.attack_from_run, PS.Act.attack_from_run, A.attack.attack_from_run),
}

var pl_action_data_list: Array[ActionData] = [
	# move
	# "Walk": ActionData.new(PS.walk,PS.Act.block, A.walk ),
	# ActionData.new(PS.small_jump_run, PS.Act.small_jump_run, A.air.small_jump_run),

	ActionData.new(PS.jump_sprint, PS.Act.jump_sprint, A.air.jump_sprint),
	ActionData.new(PS.midair, PS.Act.midair, A.air.midair),
	ActionData.new(PS.landing_sprint, PS.Act.landing_sprint, A.air.landing_sprint),
	
	ActionData.new(PS.roll, PS.Act.roll, A.roll),
	ActionData.new(PS.death, PS.Act.death, A.death),

	## attacks
	ActionData.new(PS.longsword_1, PS.Act.longsword_1, A.attack.axe_slice_1),
	ActionData.new(PS.longsword_2, PS.Act.longsword_2, A.attack.axe_slice_2),

	ActionData.new(PS.staggered, PS.Act.staggered, A.combat.staggered),
	ActionData.new(PS.parry, PS.Act.parry, A.combat.parry),
	ActionData.new(PS.parried, PS.Act.parried, A.combat.parried),
	ActionData.new(PS.riposte, PS.Act.riposte, A.combat.riposte_attack),
]
