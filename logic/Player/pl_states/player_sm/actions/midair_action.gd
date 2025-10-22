extends PlayerAction
var landing_height: float = 0.5

var terminal_velocity := -20.0


func on_enter_action(input_: InputPackage) -> void:
	__log_action_ent(pp.s("Starting vel:", get_curr_velocity()))


func update(input_: InputPackage, delta: float) -> void:
	get_player().velocity.y -= get_player().jump_data.jump_fall_gravity * delta
	
	get_player().velocity.y = max(get_player().velocity.y, terminal_velocity)
