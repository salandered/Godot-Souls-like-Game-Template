@tool
@abstract
class_name BaseSkeletonAnimatorManager
extends BaseAnimatorManager


@export var general_skeleton: Skeleton3D
@export var overlay_modifier: OverlayModifier


func __hard_dependencies() -> Array:
	var ds := super.__hard_dependencies()
	ds.append_array([
		general_skeleton,
		overlay_modifier
	])
	return ds


## OVERLAY

func set_overlay_anim(anim_id: StringName, overlay_config: OverlayConfig, start_time_offset: float = 0.0) -> void:
	if not __validation_ok(): return
	var anim: AnimationData = _anim_container.get_by_anim_id(anim_id)
	if anim == null:
		__log_error("Overlay anim not found: " + anim_id, "set_overlay_anim", "")
		return
	overlay_modifier.set_overlay_anim(anim, overlay_config, start_time_offset)


func force_stop_overlay(fade_out_duration: float = 0.2) -> void:
	overlay_modifier.force_stop_overlay()


## return -1.0 in case of problem
func get_overlay_time_left() -> float:
	if not __validation_ok(): return -1.0

	return overlay_modifier.get_time_left()

##
