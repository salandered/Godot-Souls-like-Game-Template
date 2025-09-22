extends Node
class_name Combo_

## assigned in assign_combos of PlayerState
@onready var state: PlayerState

## Combo_ result this combo invokes (eg: next_attack)
## Assigned in check_combos to queue state 
@export var state_to_trigger: String

## decides if the combo is triggered
func is_triggered(input: InputPackage) -> bool:
	push_warning("Default implementation of Combo_ is triggered")
	return false


# region: FAIR DOCS
# basic combos have one is_triggered function, and it is always called in PlayerState's check_relevance
# it seems like we are over-abstracting a bit. Why don't we
# just put a code that decides if slash_1 progresses into slash_2 in slash_1 directly and
# call this functional "slash_1 locally"?

# Well, for such a basic example as chaining consecutive strikes into series, it can be true. 
# But the purpose of Combos is to further divide the PlayerState's transition logic to enhance scalability.
# Many different factors can regulate PlayerState's transition: adrenaline level,
# fatigue level, mana/stamina statuses, some unique items in the inventory, some finishing
# limbs-choping with a random chance of procking, enemies type, 
# different buffs, all this can influent or states flow... 

# Imagine modifying it all every time adding another elif into PlayerState's _check_transition.
# With combos, you-from-the-future can work on a project for a year and then suddenly decide
# that you need some randomised heads choping finishers.
# Will it ever be easier than just creating a combo with 7-strings logic and droping it on your States?
# And we even query our combos work with get_children() collection from a PlayerState, so there is
# a fantom combo priority system being powered just by Combo_ nodes order in the editor. Sick!

# The PlayerState code is a super-basic action logic, think, 
# "what your game was with a linear inputs where every action has a hotkey and no secondary inputs", 
# the plainest, flatest implementation of your state machine without complex conditions.

# The Combos code is a module for creating additional layers of conditional transitions that can be
# added, mixed, copied and deleted without your base check_relevance function changing a symbol.
# endregion
