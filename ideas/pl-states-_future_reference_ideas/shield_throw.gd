extends PlayerState

@export var spell_release_timing: float = 1
@export var spell: PackedScene
var casted = false


func update(input_: InputPackage, _delta: float) -> void:
	if curr_state_action.works_longer_than(spell_release_timing) and not casted:
		spawn_spell()


func spawn_spell() -> void:
	var new_shield_shot: ShieldThrow = spell.instantiate()
	new_shield_shot.caster = player
	new_shield_shot.add_to_group("players_spell")
	add_child(new_shield_shot)
	new_shield_shot.global_position = player.global_position # left_wrist.global_position
	new_shield_shot.set_direction(player.basis.z)
	casted = true
	combat.shield_throw_charges = combat.shield_throw_charges - 1
	#print(combat.shield_shot_charges)


func on_enter_state(input_: InputPackage) -> void:
	casted = false
