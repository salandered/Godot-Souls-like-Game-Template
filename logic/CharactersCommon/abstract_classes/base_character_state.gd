@abstract
class_name BaseCharacterState
extends TimeManagement


var state_name: String


## not real abstract functions because args varies
## and having ...args is non intuitive

## should have this and call on_exit_state inside
# @abstract func _on_enter_state(...)


## should call on_exit_state inside!
# @abstract func _on_exit_state(...)


## for the top state this is usually called from model
# @abstract func _update(..., delta: float)