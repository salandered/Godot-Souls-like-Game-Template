extends BasePHELeaf
var decel_speed: float = 20

func update(delta):
	smooth_stop(delta)
	e_movement.apply_gravity(delta)
	me.move_and_slide()


func smooth_stop(delta):
	var horizontal_vel = Vector3(me.velocity.x, 0, me.velocity.z)
	
	horizontal_vel = horizontal_vel.move_toward(Vector3.ZERO, decel_speed * delta)
	
	me.velocity.x = horizontal_vel.x
	me.velocity.z = horizontal_vel.z