extends LegsAction

@export var accelerate_from_idle_curve: Curve

var curr_speed_time: float = 0.0 # [0,1] progress along curve
var acceleration_time: float = 0.5 # How long to reach full speed

# var speed_curve_interpolator = EaseCurveInterpolator.new()

# func _ready():
# 	SPEED = 3.0
# 	TURN_SPEED = 2
# 	ANGULAR_SPEED = 12


# var target_rotation: float = 0.0 # Radians to rotate total
# var rotation_progress: float = 0.0
# var rotation_duration: float = 0.5 # How long to complete the turn

# var remaining_rotation: float = 0.0
# const ROTATION_SPEED: float = PI # 180°/second

# func on_enter_action(input_: InputPackage) -> void:
# 	animator_manager.set_global_speed_scale(SPEED_SCALE)
# 	var input_direction := velocity_by_input(input_, 0.016).normalized()
# 	if input_direction.length() > 0.1:
# 		var face_direction = get_player().basis.z
# 		remaining_rotation = face_direction.signed_angle_to(input_direction, Vector3.UP)


# func update(input_: InputPackage, delta: float):
# 	move_with_root(delta)
	
# 	# Rotate gradually
# 	if abs(remaining_rotation) > 0.01:
# 		var rotation_this_frame = sign(remaining_rotation) * min(abs(remaining_rotation), ROTATION_SPEED * delta)
# 		get_player().rotate_y(rotation_this_frame + 0.01)
# 		remaining_rotation -= rotation_this_frame


# ## overrides
# func animate(): # ▶️
# 	var blend_time := default_blend_time
# 	var start_time_offset := 0.0
# 	match legs_sm.prev_action.action_name:
# 		Leg.Act.idle:
# 			blend_time = 0.3
# 			start_time_offset = 0.2667
# 	__log_anim(blend_time, start_time_offset)
# 	animator_manager.set_anim_to_play(anim.anim_id, blend_time, start_time_offset)
