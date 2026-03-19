class_name MechFighterNodeStateContainer
extends RefCounted


class _StateData:
	var state_name: StringName
	var anim_id: StringName

	func _init(
			state_name_: StringName,
			anim_id_: StringName,
		) -> void:
		self.state_name = state_name_
		self.anim_id = anim_id_


func get_node_to_state_data() -> Dictionary[StringName, _StateData]:
	return _node_to_state_data


var _node_to_state_data: Dictionary[StringName, _StateData] = {
	## idle
	&"Idle": _StateData.new(MFS.idle, MFA.idle_l),

	## attack
	&"AttackLR": _StateData.new(MFS.attack_lr, MFA.attack_lr),
	&"AttackRL": _StateData.new(MFS.attack_rl, MFA.attack_rl),
	&"AttackUp": _StateData.new(MFS.attack_up, MFA.attack_up),
	&"AttackDown": _StateData.new(MFS.attack_down, MFA.attack_down),
	&"AttackStab": _StateData.new(MFS.attack_stab, MFA.attack_stab),
	&"AttackLRPower": _StateData.new(MFS.attack_lr_power, MFA.attack_lr_power),
	&"AttackRLPower": _StateData.new(MFS.attack_rl_power, MFA.attack_rl_power),
	&"AttackStabPower": _StateData.new(MFS.attack_stab_power, MFA.attack_stab_power),

	## other
}
