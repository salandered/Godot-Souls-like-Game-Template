extends LegsAction


func _ready():
	default_sp.SPEED = 3.0
	default_sp.ANGULAR_SPEED = 4
	default_sp.TURN_SPEED = 2.0


func on_exit_action() -> void:
	var final_rm_speed := get_animator_manager().get_root_velocity().length()
	player_sm.fill_tranfer_data({"root_vel_speed": final_rm_speed})


func update(input_: InputPackage, delta: float):
	pm().rotate_with_input_vector(input_, delta, SpeedConfig.new(default_sp))
	pm().move_with_root(delta)
