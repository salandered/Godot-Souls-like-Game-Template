@tool
@icon("res://-assets-/x_misc/x_icons/white/icon_sword.png")
extends Node

class_name PlayerCombat


@onready var model = $".." as PlayerModel


static var _inputs_priority: Dictionary = {
	CombatAction.light_attack_pressed: 1,
	CombatAction.heavy_attack_pressed: 2,
}


func _active_weapon() -> BaseWeapon:
	return model.active_weapon


func set_hit_data(hit_damage, anim_id: String) -> void:
	var hit_data := HitData.new()
	hit_data.initialise(hit_damage, anim_id, _active_weapon())
	_active_weapon()._hit_data = hit_data
	print_.fight("PlCombat", "set hit data: " + str(hit_data))


func update_is_attacking(is_attacking: bool) -> void:
	_active_weapon().is_attacking = is_attacking


func reset_active_weapon() -> void:
	_active_weapon()._hit_data = null
	_active_weapon().hitbox_ignore_list.clear()
	_active_weapon().is_attacking = false
	print_.fight("PlCombat", "reset active weapon")


func contextualize(new_input: InputPackage, delta) -> InputPackage:
	# actualise_shieldshot(new_input)
	_translate_combat_actions(new_input, delta)
	# filter_with_resources(new_input)
	return new_input

## translates the input to basic states with the help of the current weapon
func _translate_combat_actions(new_input: InputPackage, delta):
	if new_input.combat_actions.is_empty():
		return

	new_input.combat_actions.sort_custom(_priority_sort)
	var best_action: String = new_input.combat_actions[0] # safe
	print_.fight("PlCombat", "best action is " + best_action)
	var _translated: String = model.active_weapon.translate_input_to_state(best_action, new_input, delta)
	print_.fight("PlCombat", "translated to state " + _translated)

	if _translated:
		new_input.actions.append(_translated)

# func filter_with_resources(input_: InputPackage):
# 	if model.resources.statuses.has("fatique"):
# 		input_.actions.erase("sprint")

static func _priority_sort(a: String, b: String) -> bool:
	if _inputs_priority[a] > _inputs_priority[b]:
		return true
	else:
		return false


# region: demo of magic abilities
# @export_group("spellbook")
# @export var shield_throw_charges: int = 1
# @export var max_shield_throw_charges: int = 1

# func actualise_shieldshot(new_input: InputPackage):
# 	if shield_throw_charges < 1:
# 		new_input.actions.erase("shield_throw")
# 	if shield_throw_charges == max_shield_throw_charges:
# 		new_input.actions.erase("shield_throw_reload")
# endregion
