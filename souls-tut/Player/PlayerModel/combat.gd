extends Node
class_name HumanoidCombat


@onready var model = $".." as PlayerModel

static var inputs_priority: Dictionary = {
	InputPackageCombatAction.light_attack_pressed: 1,
	InputPackageCombatAction.heavy_attack_pressed: 2,
}


func contextualize(new_input: InputPackage) -> InputPackage:
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
		# region: TODO: here another moment where state is treated as input package action
		# it's ok while InputPackageAction is subset of PlayerState
		# but ideally should be context transition (another translation oh).
		# or treat basic_attacks not as InputPackageCombatAction: PlayerState
		# but InputPackageCombatAction -> InputPackageAction ?
		# OR InputPackageAction is just PlayerState? consider this
		# endregion
		new_input.actions.append(translated_to_state)

func filter_with_resources(input: InputPackage):
	if model.resources.statuses.has("fatique"):
		input.actions.erase("sprint")

static func _priority_sort(a: String, b: String):
	if inputs_priority[a] > inputs_priority[b]:
		return true
	else:
		return false
