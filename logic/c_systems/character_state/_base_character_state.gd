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


##

# to override
func __ELA():
	return false


func __log_ent(...parts: Array):
	if __ELA():
		__log_(pp.s(state_name, pp.on_ent), pp.list_(parts))


func __log_ext(...parts: Array):
	if __ELA():
		__log_(pp.s(state_name, pp.on_ext), pp.list_(parts))


func __log_upd(...parts: Array):
	if __ELA():
		__log_(pp.s(state_name, pp.on_upd), pp.list_(parts))
