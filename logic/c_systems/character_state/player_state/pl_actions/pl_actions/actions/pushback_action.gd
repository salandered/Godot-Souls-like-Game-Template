extends PlayerAction


var fade_interpolator := FloatLinearInterpolator.new()
var DEFAULT_FADE_TIME: float = 0.4 # how long to fade extra velocity

var DEFAULT_GLOBAL_EXTRA_SPEED_Z := 0.0
var DEFAULT_GLOBAL_EXTRA_SPEED_X := 0.0

var _final_extra_speed_Z: float = 0.0
var _final_extra_speed_X: float = 0.0


func initialize() -> void:
	default_sp.ANGULAR_SPEED = 2


func on_enter_action(input_: InputPackage):
	anim = anim_container.get_by_anim_id(ra.snpick_random(A.react.hit_push_b_rm, A.react.react_dodge_B))
	__log_ent("picked random anim", pp.anim_n(anim.anim_id))
	start_time_offset.set_specific(anim.get_marker_time_by_name(MarkerName.FROM_RUN, 0.0))
	
	var r := calculate_extra_root_speed(DEFAULT_GLOBAL_EXTRA_SPEED_Z)
	_final_extra_speed_Z = r.z
	fade_interpolator.initialize(1.0, 0.0, DEFAULT_FADE_TIME)
	

func update(input_: InputPackage, delta: float):
	var fade_factor := fade_interpolator.get_current_value()
	var extra_vel_local := Vector3(_final_extra_speed_X * fade_factor, 0, _final_extra_speed_Z * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local)
	
	fade_interpolator.update(delta)
