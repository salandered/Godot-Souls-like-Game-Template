extends BaseCameraTarget
class_name CameraNest


func make_inactive() -> void:
	__log_warn("can't be inactive", "", "always true")
	_is_active = true


func make_active() -> void:
	_is_active = true


func pp_name() -> String:
	return pp.s("Nest")
