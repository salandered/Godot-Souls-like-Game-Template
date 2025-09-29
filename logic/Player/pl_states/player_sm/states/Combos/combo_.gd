extends Node
class_name Combo_

@onready var player: Princess

## Combo_ result this combo invokes (eg: next_attack)
## Assigned in check_combos to queue state 
@export var state_to_trigger: String

## decides if the combo is triggered
# TODO: use 4.5 features for abstract methods
func is_triggered(input: InputPackage) -> bool:
	push_warning("Default implementation of Combo_ is triggered")
	return false


# region: IDEAS BEHIND
# basic combo has more or less only is_triggered(), which is always called in PlayerState's check_transition
# Purpose of Combos is to further divide the PlayerState's transition logic to enhance scalability.
# Many different factors can regulate PlayerState's transition: adrenaline level,
#   	fatigue level, stamina status, unique items in the inventory, enemies type, buffs, etc
#
# Imagine modifying it all every time adding another elif into PlayerState's _check_transition.

# Also we assign combos to state using get_children(), so there may be a some 
# combo priority system being powered just by Combo_ nodes order in the editor. 
#
# The PlayerState code is a basic action logic:
# "what your game was with a linear inputs where every action has a hotkey and no secondary inputs", 
# the plainest, flatest implementation of ur SM without complex conditions.
#
# The Combos code is a module for creating additional layers of conditional transitions that can be
# added, mixed, copied and deleted withoutany change in base check_transition function.
# endregion
