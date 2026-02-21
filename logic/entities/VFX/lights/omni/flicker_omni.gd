@tool
class_name FlickerOmni
extends BaseOmni

# region Exports

@export_group("Animation & Effects")
@export var speed_scale: float = 1.0:
	set(value):
		speed_scale = value
		if is_node_ready(): _apply_playing_anim_settings()

## if true, will be used as multiplier to set energy/radius
@export var play_animation: bool = true:
	set(value):
		play_animation = value
		if is_node_ready(): _apply_playing_anim_settings()

@export var move_speed_scale: float = 1.0:
	set(value):
		move_speed_scale = value
		if is_node_ready(): _apply_playing_anim_settings()

@export var play_move_animation: bool = false:
	set(value):
		play_move_animation = value
		if is_node_ready(): _apply_playing_anim_settings()


@export_group("VOSE3D")
@export var vose_enabled: bool = true:
	set(value):
		vose_enabled = value
		if is_node_ready(): _update_vose_state()
@export var vose_whd: Vector3 = Vector3(2.0, 2.0, 2.0):
	set(value):
		vose_whd = value
		if is_node_ready(): _set_vose_aabb_whd()
## if true, vose_whd is ignored
@export var auto_vose_abb: bool = true:
	set(value):
		auto_vose_abb = value
@export var sway_padding: Vector3 = Vector3(1.0, 1.0, 1.0):
	set(value):
		sway_padding = value
## click to apply
@export var apply_auto_vose_abb_now: bool = false:
	set(value):
		apply_auto_vose_abb_now = false
		if value and is_node_ready(): _apply_auto_vose_abb()


@export_group("Animated params. DO NOT EDIT")
@export var _animated_energy_strength: float = 1.0:
	set(value):
		_animated_energy_strength = value
		if is_node_ready():
			_update_animated_values()

@export var _animated_range_strength: float = 1.0:
	set(value):
		_animated_range_strength = value
		if is_node_ready():
			_update_animated_values()

# endregion

@onready var flicker_animator: AnimationPlayer = %FlickerAnimator
@onready var move_animator: AnimationPlayer = %MoveAnimator
@onready var vose3d: VisibleOnScreenEnabler3D = %VOSE3D


class AnimID:
	const flicker = "flicker_2"
	const omni_move = "omni_move"


func _ready_implementation() -> void:
	_apply_playing_anim_settings()

	_update_vose_state()
	if auto_vose_abb:
		_apply_auto_vose_abb()
	else:
		_set_vose_aabb_whd()


func _ready_implementation_non_editor():
	__log_("_ready_implementation_non_editor")
	_assign_vose_path.call_deferred()
# 	if vose3d:
# 		SigUtils.safe_connect(vose3d.screen_entered, _on_sceen_entered)
# 		SigUtils.safe_connect(vose3d.screen_exited, _on_sceen_exited)
		
# func _on_sceen_entered():
# 	__log_("visible_on_screen_enabler_3d", "screen entered✴️")

# func _on_sceen_exited():
# 	__log_("visible_on_screen_enabler_3d", "screen exited 🚪")


func _assign_vose_path() -> void:
	__log_("_assign_vose_path")
	if vose3d:
		# Assigns the current node (self) as the target to disable
		vose3d.enable_node_path = get_path()
		__log_("_assign_vose_path", get_path(), vose3d.enable_node_path)


func _update_animated_values() -> void:
	if omni_light_3d:
		omni_light_3d.light_energy = energy * _animated_energy_strength
		omni_light_3d.omni_range = radius * _animated_range_strength


# region Apply Functions


func _apply_light_settings() -> void:
	super._apply_light_settings()
	_apply_auto_vose_abb()
	_update_animated_values()


func _apply_playing_anim_settings() -> void:
	if play_animation:
		_play_anim(flicker_animator, AnimID.flicker, speed_scale)
	if play_move_animation:
		_play_anim(move_animator, AnimID.omni_move, move_speed_scale)


func _play_anim(animator: AnimationPlayer, anim_id: String, speed_scale_: float) -> void:
	if not animator: return
	
	if animator.has_animation(anim_id):
		if not animator.is_playing() or animator.current_animation != anim_id:
			animator.play(anim_id)
			var anim_length := animator.get_animation(anim_id).length
			animator.seek(randf_range(0.0, anim_length))
		animator.speed_scale = speed_scale_
	else:
		animator.stop()


func _update_vose_state() -> void:
	if not is_inside_tree(): return
	if not vose3d: return

	if vose_enabled:
		vose3d.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		vose3d.process_mode = Node.PROCESS_MODE_DISABLED
		
		# If we don't do this, and the light was off-screen when we clicked the checkbox,
		# it would stay frozen forever.
		process_mode = Node.PROCESS_MODE_INHERIT


func _set_vose_aabb_whd() -> void:
	if not vose_enabled: return
	if not vose3d: return
	if auto_vose_abb: return
	__log_("_set_vose_aabb_whd", vose_whd)
	var centered_pos = - vose_whd / 2.0
	vose3d.aabb = AABB(centered_pos, vose_whd)


func _apply_auto_vose_abb() -> void:
	if not vose_enabled: return
	if not vose3d: return
	if not auto_vose_abb: return

	var r := radius
	__log_("_apply_auto_vose_abb", radius)
	vose3d.aabb = AABB(Vector3(-r, -r, -r) - sway_padding, Vector3(r * 2, r * 2, r * 2) + sway_padding * 2)

# endregion


## 

func __LOG_B() -> bool:
	return false
