extends PlayerAction


var VERT_SPEED_ADDED: float = 2.5

var is_jumped: bool = false

var SPEED = 5.0


func on_enter_action(input_: InputPackage) -> void:
	get_player().velocity = get_player().velocity.normalized() * SPEED


func update(input_: InputPackage, delta: float) -> void:
	if passed_marker(Marker.Name.JUMP_LAUNCH):
		if not is_jumped:
			__log_action_upd("passed_marker JUMP_LAUNCH and is_jumped false => + VERT_SPEED_ADDED")
			get_player().velocity.y += VERT_SPEED_ADDED
			is_jumped = true


func _input(event):
	VERT_SPEED_ADDED = u._dev_change_param(event, VERT_SPEED_ADDED, "VERT_SPEED_ADDED",
		5, "dev_speed_down", "dev_speed_up")
