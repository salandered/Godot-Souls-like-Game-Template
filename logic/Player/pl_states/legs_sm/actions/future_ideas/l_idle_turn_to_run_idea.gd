extends LegsAction

@export var accelerate_from_idle_curve: Curve

var ANGULAR_SPEED: float = 12
var curr_speed_time: float = 0.0 # [0,1] progress along curve
var acceleration_time: float = 0.5 # How long to reach full speed

var speed_curve_interpolator = CurveInterpolator.new()

func _ready():
	SPEED = 3.0
	TURN_SPEED = 2


var target_rotation: float = 0.0 # Radians to rotate total
var rotation_progress: float = 0.0
var rotation_duration: float = 0.5 # How long to complete the turn

var remaining_rotation: float = 0.0
const ROTATION_SPEED: float = PI # 180°/second

func on_enter_action(_input: InputPackage) -> void:
	animator_manager.set_global_speed_scale(SPEED_SCALE)
	var input_direction := velocity_by_input(_input, 0.016).normalized()
	if input_direction.length() > 0.1:
		var face_direction = player.basis.z
		remaining_rotation = face_direction.signed_angle_to(input_direction, Vector3.UP)

func update(input: InputPackage, delta: float):
	_move_with_root(delta)
	
	# Rotate gradually
	if abs(remaining_rotation) > 0.01:
		var rotation_this_frame = sign(remaining_rotation) * min(abs(remaining_rotation), ROTATION_SPEED * delta)
		player.rotate_y(rotation_this_frame + 0.01)
		remaining_rotation -= rotation_this_frame


func _move_with_root(delta: float) -> void:
	var root_vel := animator_manager.get_root_velocity()
	player.velocity = player.get_quaternion() * root_vel


## overrides
func animate(): # ▶️
	var blend_time := default_blend_time
	var start_time_offset := 0.0
	match legs_sm.prev_action.action_name:
		Leg.Act.idle:
			blend_time = 0.3
			start_time_offset = 0.2667
	__log_anim(blend_time, start_time_offset)
	animator_manager.set_anim_to_play(anim_id, blend_time, start_time_offset)
