@tool
@icon("res://-assets-/x_icons/white/icon_propeller.png")
@abstract
class_name Combo_
extends NodeLogger


@onready var player: Princess

@export var needs_curr_action: String = "not"


## next state this combo invokes (eg: next_attack)
## Will be added in check_combos to queued state 
## NOTE: state_name, not node name here
@export var state_to_trigger: String

@export var priority: int = 0 # 0 means lowest

## main method. decides if the combo is triggered
@abstract func is_triggered(input_: InputPackage, curr_state_name: String, curr_action: BaseAction) -> bool


# region: DOCS: PHILOSOPY AND DETAILS BEHIND COMBO

## Main goal - to decouple complex transition logic from the BasePlayerState
## Triggering
##		Combo relies on is_triggered(), which is called within BasePlayerState.check_transition.
## Initialization: 
##	 	Assigned via get_children() in the container, meaning the scene tree structure dictates their setup.
## Priority: Combo has a priority property. Order of the combo nodes doesn't matter.
##
## endregion


func __LOG_B() -> bool:
	return false