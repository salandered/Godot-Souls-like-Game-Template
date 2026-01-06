@tool
@icon("res://-assets-/x_icons/level/icon_level_red.png")

@abstract
class_name BaseLevel
extends Node3DSystem


@export_category("Nodes to validate")
@export var is_pause_menu_controller: bool = true
@export var is_world_environment: bool = true


var _world_env: WorldEnvironment

var tone_map_exposure := FMinMax.new(0.2, 2.0)


var fog_volumes_in_scene: Array[FogVolume] = []
var direct_lights_in_scene: Array[DirectionalLight3D] = []

@abstract func basic_tonemap_exposure() -> float

@abstract func tonemap_exposure_no_vol_fog_compensation() -> float


@abstract func initialise() -> void


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if is_pause_menu_controller:
		_validate_pause_menu_controller_on_init()
	if is_world_environment:
		_validate_world_env_on_init()

		## WARNING: currently use only visible objects
		## E.g.: If game logic would make volume visible later, this would bypass the setting
		fog_volumes_in_scene = get_descendants.fog_volumes(self, true)
		direct_lights_in_scene = get_descendants.directional_lights_3d(self, true)

		update_video_settings()

	if not GlobalSignal.SIG_update_video_settings_for_level.is_connected(_on_update_video_settings):
		GlobalSignal.SIG_update_video_settings_for_level.connect(_on_update_video_settings)
	
	initialise()


func update_video_settings():
	set_world_env_volumetric_fog_from_settings()
	set_world_env_tonemap_exposure_from_settings()
	set_shadow_mode_from_settings()


func _validate_pause_menu_controller_on_init():
		var nodes := get_descendants.pause_menu_controller(self)
		error_.empty_list(nodes, "no pause_menu_controller found in the level scene")
		if len(nodes) > 1:
			error_.warn("several pause_menu_controller found in the level scene. It's weird", "", "")


func _validate_world_env_on_init():
	var nodes := get_descendants.world_environments(self)
	if error_.empty_list(nodes, "no world_environment found in the level scene"):
		_world_env = null
		return
	if len(nodes) > 1:
		error_.warn("several world_environment found in the level scene. It's weird", "", "")
	_world_env = nodes[0]
	error_.null_object(_world_env.environment)


func set_world_env_tonemap_exposure_from_settings():
	var value_from_settings := M_AppSettings.get_brightness()
	var value_from_settings_vol_fog := M_AppSettings.get_volumetric_fog()
	if _validate_world_env(pp.s("set_world_env_tonemap_exposure_from_settings🎨", value_from_settings)):
		var curr_exposure := _world_env.environment.tonemap_exposure
		var new_exposure := basic_tonemap_exposure() + value_from_settings - 1.0
		if not value_from_settings_vol_fog:
			new_exposure += tonemap_exposure_no_vol_fog_compensation()
		__log_("set_world_env_tonemap_exposure_from_settings🎨",
			"value_from_settings", pp.in_q(value_from_settings),
			"curr_exposure", pp.in_q(curr_exposure),
			"value_from_settings_vol_fog", pp.in_q(value_from_settings_vol_fog),
			"base_env_exposure", pp.in_q(basic_tonemap_exposure()),
			"tonemap_exposure_no_vol_fog_compensation", pp.in_q(tonemap_exposure_no_vol_fog_compensation()),
			"=> new_exposure will be", pp.in_q(new_exposure))

		new_exposure = tone_map_exposure.clamp(new_exposure)
		_world_env.environment.tonemap_exposure = new_exposure


func set_world_env_volumetric_fog_from_settings():
	var value_from_settings := M_AppSettings.get_volumetric_fog()

	if _validate_world_env(pp.s("set_world_env_volumetric_fog", value_from_settings)):
		__log_("set_world_env_volumetric_fog", "value_from_settings will be set:", pp.in_q(value_from_settings))
		_world_env.environment.volumetric_fog_enabled = value_from_settings
		for item: FogVolume in fog_volumes_in_scene:
			item.visible = value_from_settings

		## recalculate exposure
		set_world_env_tonemap_exposure_from_settings()

func set_shadow_mode_from_settings():
	var value_from_settings := M_AppSettings.get_shadow_mode()
	var mode: DirectionalLight3D.ShadowMode = M_AppSettings.shadow_mode_number_to_val.get(value_from_settings)
	for item: DirectionalLight3D in direct_lights_in_scene:
			item.shadow_enabled = true
			item.directional_shadow_mode = mode
			if value_from_settings == 3:
				item.shadow_enabled = false


func _validate_world_env(context: String = "") -> bool:
	if _world_env and _world_env.environment:
		return true
	else:
		__log_warn_soft(
			"no world env or _world_env.environment",
			"_validate_world_env",
			"",
			context)
		return false


func _on_update_video_settings() -> void:
	update_video_settings()


func __LOG_B() -> bool:
	return false