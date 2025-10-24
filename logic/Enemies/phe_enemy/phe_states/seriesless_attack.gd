extends BasePHState


var hit_damage: float = 30
@export var next_attacks: Array[BasePHState]
@export var pushes_back: bool = false
@export_group("bad assets adjustment")
@export var angle_adjustment: float = 0 # radians
@export var tracking_angular_speed: float = 1


func check_transition(_delta) -> VerdictPH:
	if player_too_far():
		var gapclosing_method = ["gapclose", "pursuit"].pick_random()
		return VerdictPH.new(gapclosing_method)
	if player_too_close():
		return VerdictPH.new("kick")
	if works_longer_than(get_animation_length()):
		return VerdictPH.new(next_attacks.pick_random().state_name)
	return VerdictPH.new()

func player_too_far() -> bool:
	return works_longer_than(get_animation_length()) and distance_to_player() > get_parent().pursuit_radius

func player_too_close() -> bool:
	return works_longer_than(get_animation_length()) and distance_to_player() < get_parent().scare_off_radius and state_name != "kick"


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


# func pack_hit_data(weapon: BaseWeapon) -> HitData:
# 	var hit = HitData.new()
# 	hit.damage = hit_damage
# 	hit.state_anim = animation
# 	# hit.is_parryable = is_parryable()
# 	if pushes_back:
# 		hit.effects["pushback"] = true
# 		hit.effects["pushback_direction"] = projected_direction_to_player()
# 	hit.weapon = weapon
# 	return hit


func on_exit():
	deactivate_weapons()
