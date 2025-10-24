extends BasePHState


var speed: float = 1.5
@export var tracking_angular_speed: float = 2

func check_transition(_delta):
	return VerdictPH.new()


func update(delta: float):
	var face_direction = me.basis.z
	var angle = face_direction.signed_angle_to(projected_direction_to_player(), Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		me.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * speed
		me.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		me.velocity = face_direction.rotated(Vector3.UP, angle) * speed
		me.rotate_y(angle)
	
	# me.look_at(get_projected_player_pos(), Vector3.UP, true)
	# me.velocity = me.basis.z * speed
	me.move_and_slide()
