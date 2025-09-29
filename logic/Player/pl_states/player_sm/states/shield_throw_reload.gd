extends PlayerState

@export var charge_restore_timing: float = 3.5
var reloaded = false

func update(_input, _delta):
	if current_action.works_longer_than(charge_restore_timing) and not reloaded:
		combat.shield_throw_charges = combat.shield_throw_charges + 1
		reloaded = true


func on_exit_state():
	reloaded = false
