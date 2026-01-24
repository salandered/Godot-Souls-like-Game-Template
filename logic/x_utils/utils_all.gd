extends RefCounted
# here are all utils which dont have their separate more focused module (yet)
class_name u

static var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


## small division error, we dont care
static func get_curr_time_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func sfr(str_prefix: bool = false) -> Variant:
	if not str_prefix:
		return str(Engine.get_process_frames())
	return pp.s("fr_n-", Engine.get_process_frames())

static func ifr() -> int:
	return Engine.get_process_frames()


static func is_nth_frame(interval: int) -> bool:
	if interval <= 0: return true
	return ifr() % interval == 0


static func is_nth_physics_frame(interval: int) -> bool:
	if interval <= 0: return true
	return Engine.get_physics_frames() % interval == 0


# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))


static func safe_look_at(
		from_who: Node3D,
		target: Vector3,
		up: Vector3 = Vector3.UP,
		# by default -Z is pointed to target. built-in use_model_front solves that
		use_model_front: bool = false,
		eps: float = 0.001
) -> bool:
	var dir := target - from_who.global_transform.origin
	if dir.length_squared() < eps * eps:
		return false
	if abs(dir.normalized().dot(up)) > 1.0 - eps:
		return false
	from_who.look_at(target, up, use_model_front)
	return true


## point_index starts with zero!
static func get_curve_point_x(curve: Curve, point_index: int) -> float:
	return curve.get_point_position(point_index).x


static func reset_all(resettable: Array):
	for item in resettable:
		if item.has_method("reset"):
			item.reset()


static func fpow2(number: float) -> float:
	return number * number

static func ipow2(number: int) -> int:
	return number * number


##

static func set_all_descendant_asp_3d_default_bus(for_whom: Node3D):
	var asps := get_descendants.audio_stream_players_3D(for_whom)
	for asp: AudioStreamPlayer3D in asps:
		asp.bus = Constants.SFX_ASP_BASE_BUS_ID

##


static func _recursive_hide(
		node: Node,
		filter: Callable,
		__log: bool = false
	):
	for child in node.get_children():
		if filter.call(child) and child is Node3D:
			if __log and child.visible:
				prints("~~//", child.name, "is hidden")
			child.visible = false
		_recursive_hide(child, filter, __log)


static func hide_dev_visuals(node: Node, __log: bool = false):
	_recursive_hide(
		node,
		func(n): return n.name.begins_with("__dev") or n.name.begins_with("__test"),
		__log
	)


## DEV
# region

static func _dev_change_t12_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t1, RawAction.t2, require_ctrl)

static func _dev_change_t34_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t3, RawAction.t4, require_ctrl)

static func _dev_change_t58_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t5, RawAction.t8, require_ctrl)

static func _dev_change_t67_param(event, param, param_name: String = "some param", step: float = 0.1,
	require_ctrl: bool = false) -> Variant:
	return _dev_change_param(event, param, param_name, step, RawAction.t6, RawAction.t7, require_ctrl)

static func _dev_change_param(
	event: InputEvent,
	param: Variant,
	param_name: String = "some param",
	step: float = 0.1,
	key_a: String = RawAction.t1,
	key_b: String = RawAction.t2,
	require_ctrl: bool = false
) -> Variant:
	var prev_param: Variant = param

	if require_ctrl and not event.is_ctrl_pressed():
		return param

	if event.is_action_released(key_a):
		param -= step
	if event.is_action_released(key_b):
		param += step

	if prev_param != param:
		print_.dev("~~ ", pp.s(param_name, prev_param, pp.arr, param))
	return param

# endregion
