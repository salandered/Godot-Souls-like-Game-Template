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


var node_to_player_state_data: Dictionary = { # { Node name : StateData }
	# move
	# "Walk": StateData.new(PS.walk, 2),
	# TODO: seems like depends_on_legs_ true equals to having not legs_double_beh default
	"Idle": StateData.new(PS.idle, 1, Leg.Beh.idle, true),
	"Run": StateData.new(PS.run, 2, Leg.Beh.run, true),
	"Strafe": StateData.new(PS.strafe, 3),
	"Sprint": StateData.new(PS.sprint, 3, Leg.Beh.sprint, true),
	"JumpRun": StateData.new(PS.jump_run, 10),
	"JumpSprint": StateData.new(PS.jump_sprint, 10),
	"Midair": StateData.new(PS.midair, 10),
	"LandingRun": StateData.new(PS.landing_run, 10),
	"LandingSprint": StateData.new(PS.landing_sprint, 10),
	"Roll": StateData.new(PS.roll, 20),
	"Death": StateData.new(PS.death, 200),
	# fight
	"Longsword1": StateData.new(PS.longsword_1, 15),
	"Longsword2": StateData.new(PS.longsword_2, 15),
	"Block": StateData.new(PS.block, 21, Leg.Beh.run),
	"BlockReaction": StateData.new(PS.block_reaction, 90),
	"Withdraw": StateData.new(PS.withdraw, 15),
	"ShieldThrow": StateData.new(PS.shield_throw, 16),
	"ShieldThrowReload": StateData.new(PS.shield_throw_reload, 17),
	"Pushback": StateData.new(PS.pushback, 101),
	"Staggered": StateData.new(PS.staggered, 100),
	"Parry": StateData.new(PS.parry, 20),
	"Parried": StateData.new(PS.parried, 100),
	"Riposte": StateData.new(PS.riposte, 25),

}


var node_to_player_action_data: Dictionary = { # { Node name : ActionData }
	# move
	# "Walk": ActionData.new(PS.walk,PS.action_block, A.walk ),
	"StrafeAction": ActionData.new(PS.strafe, PS.action_strafe, A.run_R),
	"JumpRunAction": ActionData.new(PS.jump_run, PS.action_jump_run, A.jump_run),
	"JumpSprintAction": ActionData.new(PS.jump_sprint, PS.action_jump_sprint, A.jump_sprint),
	"MidairAction": ActionData.new(PS.midair, PS.action_midair, A.midair),
	"LandingRunAction": ActionData.new(PS.landing_run, PS.action_landing_run, A.landing_run),
	"LandingSprintAction": ActionData.new(PS.landing_sprint, PS.action_landing_sprint, A.landing_sprint),
	"RollAction": ActionData.new(PS.roll, PS.action_roll, A.roll),
	"DeathAction": ActionData.new(PS.death, PS.action_death, A.death),
	# fight
	"Longsword1Action": ActionData.new(PS.longsword_1, PS.action_longsword_1, A.longsword_1),
	"Longsword2Action": ActionData.new(PS.longsword_2, PS.action_longsword_2, A.longsword_2),
	"BlockAction": ActionData.new(PS.block, PS.action_block, A.block_forward),
	"BlockReactionAction": ActionData.new(PS.block_reaction, PS.action_block_reaction, A.block_reaction),
	"WithdrawAction": ActionData.new(PS.withdraw, PS.action_withdraw, A.withdraw),
	"ShieldThrowAction": ActionData.new(PS.shield_throw, PS.action_shield_throw, A.shield_throw),
	"ShieldThrowReloadAction": ActionData.new(PS.shield_throw_reload, PS.action_shield_throw_reload, A.shield_throw_reload),
	"PushbackAction": ActionData.new(PS.pushback, PS.action_pushback, A.pushback),
	"StaggeredAction": ActionData.new(PS.staggered, PS.action_staggered, A.staggered),
	"ParryAction": ActionData.new(PS.parry, PS.action_parry, A.parry),
	"ParriedAction": ActionData.new(PS.parried, PS.action_parried, A.parried),
	"RiposteAction": ActionData.new(PS.riposte, PS.action_riposte, A.riposte_attack),
}
