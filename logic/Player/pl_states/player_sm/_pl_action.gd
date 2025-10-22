extends BaseAction
class_name PlayerAction


## to override if needed
func initialise() -> void:
	pass


# not abstract
func update(input_: InputPackage, _delta: float):
	pass


func __log_action_ent(...parts: Array):
	print_.psm_action(action_name + pp.on_ent, pp.list_(parts))


func __log_action_upd(...parts: Array):
	print_.psm_action(action_name + pp.on_upd, pp.list_(parts))


func __log_action_ext(...parts: Array):
	print_.psm_action(action_name + pp.on_ext, pp.list_(parts))

func __log_action(...parts: Array):
	print_.psm_action(action_name, pp.list_(parts))