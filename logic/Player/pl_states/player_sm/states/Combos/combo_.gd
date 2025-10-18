@abstract
class_name Combo_
extends Node

@onready var player: Princess

## next state this combo invokes (eg: next_attack)
## Will be added in check_combos to queued state 
@export var state_to_trigger: String

## main method. decides if the combo is triggered
@abstract func is_triggered(input_: InputPackage) -> bool


# region: DOCS: PHILOSOPY AND DETAILS BEHIND COMBO
#
# Basic combo has more or less only is_triggered(), which is always called in PlayerState's check_transition
# We assign combos to state using get_children() in container. So node structure dictates their initialisation.
# 
# Purpose of Combos is to divide the PlayerState's transition logic.
#   - Many different factors can regulate PlayerState's transition: adrenaline level,
#   	fatigue level, stamina status, unique items in the inventory, enemies type, buffs, etc
#   - Imagine modifying it all every time adding another elif into PlayerState's _check_transition.
#   - The PlayerState code is a basic action logic with simple input actions interpretation.
#   - The Combos code is a module for creating additional layers of conditional transitions that can be
#     added, mixed, copied and deleted without any change in base check_transition function.
# 		(idea: combo priority system being powered nodes order)
#
# endregion
