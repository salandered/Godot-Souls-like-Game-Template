extends RefCounted
class_name StatesContainer


class _StateData:
	var state_name: String
	var priority: int
	var legs_behavior_name: String
	var depends_on_legs: bool
	var stamina_cost: float

	func _init(
			state_name_: String,
			priority_: int,
			legs_behavior_name_: String = Leg.Beh.double,
			depends_on_legs_: bool = false,
			stamina_cost_: float = 0.0

		) -> void:
		self.state_name = state_name_
		self.priority = priority_
		self.legs_behavior_name = legs_behavior_name_
		self.depends_on_legs = depends_on_legs_
		self.stamina_cost = stamina_cost_


class _ActionData:
	var state_name: String
	var action_name: String
	var anim_id: String
	var motion_type: String

	func _init(
			state_name_: String,
			action_name_: String,
			anim_id_: String,
			motion_type_: String,

		) -> void:
		self.state_name = state_name_
		self.action_name = action_name_
		self.anim_id = anim_id_
		self.motion_type = motion_type_


var node_to_pl_state_data: Dictionary = { # { Node name : _StateData }
	# move
	# TODO: seems like depends_on_legs_ true equals to having not legs_double_beh default
	"Idle": _StateData.new(PS.idle, 1, Leg.Beh.idle, true),
	"Run": _StateData.new(PS.run, 2, Leg.Beh.run, true),
	"Strafe": _StateData.new(PS.strafe, 2, Leg.Beh.strafe, true),
	# Sprint drains stamina, but costs just a bit as well
	"Sprint": _StateData.new(PS.sprint, 3, Leg.Beh.sprint, true, 0.5),
	
	"Dodge": _StateData.new(PS.dodge, 10, Leg.Beh.double, false, 5.0),
	
	"JumpSprint": _StateData.new(PS.jump_sprint, 10, Leg.Beh.double, false, 10.0),
	"Midair": _StateData.new(PS.midair, 10, Leg.Beh.double, false, 0.0),
	"LandingSprint": _StateData.new(PS.landing_sprint, 10, Leg.Beh.double, false, 0.0),
	"Roll": _StateData.new(PS.roll, 20, Leg.Beh.double, false, 5.0),
	"Death": _StateData.new(PS.death, 200, Leg.Beh.double, false, 0.0),

	## Attacks
	"AxeSlice1": _StateData.new(PS.axe_slice_1, 15, Leg.Beh.double, false, 10.0),
	"AxeSlice2": _StateData.new(PS.axe_slice_2, 15, Leg.Beh.double, false, 12.0),
	# priority a bit higher
	"AttackFromRun": _StateData.new(PS.attack_from_run, 16, Leg.Beh.double, false, 8.0),

	"SwordSlash1": _StateData.new(PS.sword_slash_1, 15, Leg.Beh.double, false, 10.0),
	"SwordSlash2": _StateData.new(PS.sword_slash_2, 15, Leg.Beh.double, false, 12.0),

	# 
	"Staggered": _StateData.new(PS.staggered, 100, Leg.Beh.double, false, 0.0),
	"Parry": _StateData.new(PS.parry, 20, Leg.Beh.double, false, 5.0),
	"Parried": _StateData.new(PS.parried, 100, Leg.Beh.double, false, 5.0),
	"Riposte": _StateData.new(PS.riposte, 25, Leg.Beh.double, false, 5.0),
}


## PLAYER ACTIONS

var node_to_pl_action: Dictionary = { # { Node name : _ActionData }
	"_DoubleAction": _ActionData.new(PS.for_double, PS.Act.double, A.air.midair, MotionType.IDLE),
	
	#
	"DodgeAction": _ActionData.new(PS.dodge, PS.Act.dodge, A.dodge.dodge_R, MotionType.START),

	## air
	"JumpSprintAction": _ActionData.new(PS.jump_sprint, PS.Act.jump_sprint, A.air.jump_sprint, MotionType.START),
	"MidairAction": _ActionData.new(PS.midair, PS.Act.midair, A.air.midair, MotionType.LOOP),
	"LandingSprintAction": _ActionData.new(PS.landing_sprint, PS.Act.landing_sprint, A.air.landing_sprint, MotionType.LOOP),

	## attacks
	"AxeSlice1Action": _ActionData.new(PS.axe_slice_1, PS.Act.axe_slice_1, A.attack.axe_slice_1, MotionType.IDLE),
	"AxeSlice2Action": _ActionData.new(PS.axe_slice_2, PS.Act.axe_slice_2, A.attack.axe_slice_2, MotionType.IDLE),
	"AttackFromRunAction": _ActionData.new(PS.attack_from_run, PS.Act.attack_from_run, A.attack.attack_from_run, MotionType.IDLE),
	
	"SwordSlash1Action": _ActionData.new(PS.sword_slash_1, PS.Act.sword_slash_1, A.attack.sword_slash_1, MotionType.IDLE),
	"SwordSlash2Action": _ActionData.new(PS.sword_slash_2, PS.Act.sword_slash_2, A.attack.sword_slash_2, MotionType.IDLE),
}

var pl_action_data_list: Array[_ActionData] = [

	_ActionData.new(PS.roll, PS.Act.roll, A.roll, MotionType.START),
	_ActionData.new(PS.death, PS.Act.death, A.death, MotionType.IDLE),

	## attacks

	_ActionData.new(PS.staggered, PS.Act.staggered, A.combat.staggered, MotionType.IDLE),
	_ActionData.new(PS.parry, PS.Act.parry, A.combat.parry, MotionType.IDLE),
	_ActionData.new(PS.parried, PS.Act.parried, A.combat.parried, MotionType.IDLE),
	_ActionData.new(PS.riposte, PS.Act.riposte, A.combat.riposte_attack, MotionType.IDLE),
]
