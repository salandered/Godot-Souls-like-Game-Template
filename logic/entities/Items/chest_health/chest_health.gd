extends Node3DSystem
class_name ChestHealth


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_item: HealthItem = %HealthItem
@onready var dev_cam: Camera3D = %dev_cam
@onready var interact_area: InteractArea = %InteractArea


func get_hard_dependencies() -> Array[Object]:
	return [
		animation_player
	]

func get_soft_dependencies() -> Array[Object]:
	return [
		interact_area,
		health_item
	]

class AnimID:
	const open = "open"


func _ready() -> void:
	#if dev_cam:
		#dev_cam.current = false
	if health_item:
		health_item.set_interact_area_enable(false)
	var valid_ok := _validation()
	if valid_ok:
		__validate_deps_set_init()
		animation_player.animation_finished.connect(_on_animation_finished)
		interact_area.SIG_interacted.connect(_on_my_area_interacted)


func _validation() -> bool:
	var r = AnimUtils.safe_has_animation(animation_player, AnimID.open)
	return r


func open():
	if __could_not_initialised():
		return

	__log_("open", "opening")
	
	animation_player.play(AnimID.open)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		AnimID.open:
			__log_("_on_animation_finished", "open")
			if health_item:
				health_item.set_interact_area_enable(true)


func _on_my_area_interacted():
	if not interact_area.ENABLED:
		__log_("_on_my_area_interacted", "not interact_area.enabled")
		return
	interact_area.ENABLED = false

	__log_("_on_my_area_interacted", "triggered")
	open()


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
		
	if event.is_action_pressed(RawAction.DEV_H):
		open()


func _is_run_directly() -> bool:
	# The scene currently running as the 'root' of the gameplay
	var current_scene = get_tree().current_scene
	if not current_scene:
		return false
		
	# The scene defined in Project Settings > Run > Main Scene
	var main_scene_path = ProjectSettings.get_setting("application/run/main_scene")
	
	# If the paths don't match, we are running a specific scene (F6)
	return current_scene.scene_file_path != main_scene_path
