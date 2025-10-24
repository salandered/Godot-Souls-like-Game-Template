extends BasePHState


var hit_damage: float = 30
@export var next_attacks: Array[BasePHState]
@export_group("bad assets adjustment")
@export var angle_adjustment: float = 0 # radians
@export var tracking_angular_speed: float = 1


func on_enter():
	get_parent().attacks_to_do -= 1
	combat.set_hit_data_to_active_weapon(hit_damage, animation)


func on_exit():
	combat.reset_active_weapon()

	deactivate_weapons()


func check_transition(_delta) -> VerdictPH:
	if works_longer_than(get_animation_length()):
		if get_parent().attacks_to_do > 0:
			return VerdictPH.new(next_attacks.pick_random().state_name)
		get_parent().ended = true
	return VerdictPH.new()


func update(delta):
	rotate_character(delta)
	move_character(delta)
	manage_weapons()


func rotate_character(delta):
	var adjusted_direction = direction_to_player().rotated(Vector3.UP, angle_adjustment)
	
	var face_direction = me.basis.z
	var angle = face_direction.signed_angle_to(adjusted_direction, Vector3.UP)
	me.rotate_y(clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))
	# lazier way, looks more tripy: me.look_at(me.global_position + adjusted_direction, Vector3.UP, true)


func move_character(delta):
	var delta_pos = get_root_position_delta(delta)
	delta_pos.y = 0
	me.velocity = me.get_quaternion() * delta_pos / delta
	if not me.is_on_floor():
		me.velocity.y -= u.gravity * delta
	me.move_and_slide()
