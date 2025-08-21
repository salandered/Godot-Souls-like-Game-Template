extends Node
class_name HumanoidCombat


@onready var model = $".." as PlayerModel

@export_group("spellbook")
@export var shield_throw_charges: int = 1
@export var max_shield_throw_charges: int = 1


static var inputs_priority: Dictionary = {
	InDataCombatAction.light_attack_pressed: 1,
	InDataCombatAction.heavy_attack_pressed: 2,
}


func contextualize(new_input: InputPackage) -> InputPackage:
	TEMP_actualise_shieldshot(new_input)
	translate_combat_actions(new_input)
	filter_with_resources(new_input)
	return new_input

## Input creates an input package.
## Combat system translates this input to basic states with the help of the current weapon.
func translate_combat_actions(new_input: InputPackage):
	if not new_input.combat_actions.is_empty():
		new_input.combat_actions.sort_custom(_priority_sort)
		var prioritized_action: String = new_input.combat_actions[0] # safe
		var translated_to_state: String = model.active_weapon.basic_attacks[prioritized_action]
		new_input.actions.append(translated_to_state)

func filter_with_resources(input: InputPackage):
	if model.resources.statuses.has("fatique"):
		input.actions.erase("sprint")

static func _priority_sort(a: String, b: String) -> bool:
	if inputs_priority[a] > inputs_priority[b]:
		return true
	else:
		return false


# This all has a temporary fleur because of inability to create a "tutorial" for spells and special abilities.
# While there are low amounts of WASD controllers, and there's a very limited
# number of ideas about i-frames, dodges, parries or melee hits,
# considering magic systems and special abilities, there are pretty much a system per game.
# So, there won't be an ultimate clean design for a spell until you'll start to create an actual game.
# Generally, of course spellbook must be a separate layer, and combat must filter the inputs using
# delegate calls to spellbook logic.
func TEMP_actualise_shieldshot(new_input: InputPackage):
	if shield_throw_charges < 1:
		new_input.actions.erase("shield_throw")
	if shield_throw_charges == max_shield_throw_charges:
		new_input.actions.erase("shield_throw_reload")
