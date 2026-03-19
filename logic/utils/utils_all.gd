class_name tu # TemporaryUtils
extends RefCounted


## All utils which don't have their separate more focused module yet


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


## NOTE: point_index starts with zero
static func get_curve_point_x(curve: Curve, point_index: int) -> float:
	return curve.get_point_position(point_index).x


static func reset_all(resettable: Array):
	for item in resettable:
		if item.has_method("reset"):
			item.reset()


static func set_all_descendant_asp_3d_default_bus(for_whom: Node3D):
	var asps := get_descendants.audio_stream_players_3D(for_whom)
	for asp: AudioStreamPlayer3D in asps:
		asp.bus = Const.SFX_ASP_BASE_BUS_ID


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


static func wait_seconds(for_whom: Node, duration: float) -> void:
	if not for_whom: return
	if not for_whom.get_tree(): return
	await for_whom.get_tree().create_timer(duration).timeout