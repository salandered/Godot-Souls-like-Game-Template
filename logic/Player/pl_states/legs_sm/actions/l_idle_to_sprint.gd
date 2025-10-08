extends LegsAction


func _ready():
	SPEED = 3.0
	ANGULAR_SPEED = 4
	TURN_SPEED = 2.0


func on_exit_action() -> void:
	var final_rm_speed = animator_manager.get_root_velocity().length()
	legs_sm.fill_tranfer_data({"rm_speed": final_rm_speed})


func update(input: InputPackage, delta: float):
	rotate_with_input_vector(input, delta)
	move_with_root(delta)
