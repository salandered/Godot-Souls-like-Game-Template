extends RefCounted
## All utils which don't have their separate more focused module yet
class_name u


## small division error, we dont care
static func get_curr_time_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func get_time_string_from_system_mm_ss() -> String:
	var time := Time.get_time_string_from_system()
	var mm_ss := time.right(5) if len(time) >= 5 else time
	return mm_ss


static func sfr(str_prefix: bool = false) -> String:
	if not str_prefix:
		return str(Engine.get_process_frames())
	return pp.s("fr_n-", Engine.get_process_frames())


static func ifr() -> int:
	return Engine.get_process_frames()


static func is_nth_frame(interval: int) -> bool:
	if interval <= 1: return true
	return ifr() % interval == 0


static func is_nth_physics_frame(interval: int) -> bool:
	if interval <= 1: return true
	return Engine.get_physics_frames() % interval == 0


static func safe_look_at(
		from_who: Node3D,
		target: Vector3,
		up: Vector3 = Vector3.UP,
		# by default -Z is pointed to target. built-in 'use_model_front' solves that
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
				print_.dev("_recursive_hide", child.name, "is hidden")
			child.visible = false
		_recursive_hide(child, filter, __log)


static func hide_dev_visuals(node: Node, __log: bool = false):
	_recursive_hide(
		node,
		func(n): return n.name.begins_with("__dev") or n.name.begins_with("__test"),
		__log
	)

##

static func pause_tree_toggle(for_whom: Node) -> void:
	if not for_whom: return
	if not for_whom.get_tree(): return
	for_whom.get_tree().paused = not for_whom.get_tree().paused

##

static func is_editor() -> bool:
	return Engine.is_editor_hint()


static func is_release() -> bool:
	return not OS.is_debug_build()
