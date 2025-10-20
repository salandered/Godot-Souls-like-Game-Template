extends BaseAction
class_name PlayerAction

## every player action has a direct access to its state.
var parent_state: PlayerState


## to override if needed
func initialise() -> void:
	pass


# not abstract
func update(input_: InputPackage, _delta: float):
	pass


func get_player() -> Princess:
	return player_sm.player


func pm() -> PlayerMovement:
	return player_sm.player_movement


func _on_exit_action() -> void:
	# __log_action_ext("🚪Exited!")
	on_exit_action()


func __log_action_ent(...parts: Array):
	print_.psm_action(action_name + pp.on_ent, pp.list_(parts))

func __log_action_ext(...parts: Array):
	print_.psm_action(action_name + pp.on_ext, pp.list_(parts))

func __log_action(...parts: Array):
	print_.psm_action(action_name, pp.list_(parts))