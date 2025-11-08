extends PlayerAction


var fade_interpolator := FloatLinearInterpolator.new()
var DEFAULT_FADE_TIME: float = 0.4 # how long to fade extra velocity

var DEFAULT_GLOBAL_EXTRA_SPEED_Z := 0.0
var DEFAULT_GLOBAL_EXTRA_SPEED_X := 0.0

var _final_extra_speed_Z: float = 0.0
var _final_extra_speed_X: float = 0.0


func initialise() -> void:
	default_sp.ANGULAR_SPEED = 2


func on_enter_action(input_: InputPackage):
	var r = calculate_extra_root_speed(DEFAULT_GLOBAL_EXTRA_SPEED_Z)
	_final_extra_speed_Z = r.z
	fade_interpolator.initialise(1.0, 0.0, DEFAULT_FADE_TIME)
	

func _calculate_final_speed_x(extra_speed_x: float) -> float:
	var _r := extra_speed_x
	__log_ent("extraSp X", _r)
	return _r


func update(input_: InputPackage, delta):
	var fade_factor := fade_interpolator.get_current_value()
	var extra_vel_local := Vector3(_final_extra_speed_X * fade_factor, 0, _final_extra_speed_Z * fade_factor) # Animation +Z
	
	pm().move_with_root(delta, extra_vel_local)
	
	fade_interpolator.update(delta)
