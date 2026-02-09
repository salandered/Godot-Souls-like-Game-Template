class_name WorldVideoSettingSetup
extends RefCountedStaticLogger


static var tone_map_exposure_mm := FMinMax.new(0.2, 2.0)


static func set_world_env_tonemap_exposure_from_settings(_world_env: WorldEnvironment,
	basic_tonemap_exposure: float,
	tonemap_exposure_no_vol_fog_compensation: float
):
	var value_from_settings := M_AppSettings.get_brightness()
	var value_from_settings_vol_fog := M_AppSettings.get_volumetric_fog()
	if _validate_world_env(_world_env, pp.s("set_world_env_tonemap_exposure_from_settings🎨", value_from_settings)):
		var curr_exposure := _world_env.environment.tonemap_exposure
		var new_exposure := basic_tonemap_exposure + value_from_settings - 1.0
		if not value_from_settings_vol_fog:
			new_exposure += tonemap_exposure_no_vol_fog_compensation
		__log_("set_world_env_tonemap_exposure_from_settings🎨",
			"value_from_settings", pp.in_q(value_from_settings),
			"curr_exposure", pp.in_q(curr_exposure),
			"value_from_settings_vol_fog", pp.in_q(value_from_settings_vol_fog),
			"base_env_exposure", pp.in_q(basic_tonemap_exposure),
			"tonemap_exposure_no_vol_fog_compensation", pp.in_q(tonemap_exposure_no_vol_fog_compensation),
			"=> new_exposure will be", pp.in_q(new_exposure))

		new_exposure = tone_map_exposure_mm.clamp(new_exposure)
		_world_env.environment.tonemap_exposure = new_exposure


static func set_world_env_volumetric_fog_from_settings(_world_env: WorldEnvironment,
	fog_volumes_in_scene: Array[FogVolume],
	basic_tonemap_exposure: float,
	tonemap_exposure_no_vol_fog_compensation: float
):
	var value_from_settings := M_AppSettings.get_volumetric_fog()

	if _validate_world_env(_world_env, pp.s("set_world_env_volumetric_fog", value_from_settings)):
		__log_("set_world_env_volumetric_fog", "value_from_settings will be set:", pp.in_q(value_from_settings))
		_world_env.environment.volumetric_fog_enabled = value_from_settings
		for item: FogVolume in fog_volumes_in_scene:
			item.visible = value_from_settings

		## recalculate exposure
		set_world_env_tonemap_exposure_from_settings(_world_env, basic_tonemap_exposure, tonemap_exposure_no_vol_fog_compensation)


static func set_shadow_mode_from_settings(direct_lights_in_scene: Array[DirectionalLight3D]):
	var value_from_settings := M_AppSettings.get_shadow_mode()
	var mode: DirectionalLight3D.ShadowMode = M_AppSettings.shadow_mode_number_to_val.get(value_from_settings)
	for item: DirectionalLight3D in direct_lights_in_scene:
		item.shadow_enabled = true
		item.directional_shadow_mode = mode
		if value_from_settings == 3:
			item.shadow_enabled = false


static func _validate_world_env(_world_env: WorldEnvironment, context: String = "") -> bool:
	if _world_env and _world_env.environment:
		return true
	else:
		__log_warn_soft(
			"no world env or _world_env.environment",
			"_validate_world_env",
			"",
			context)
		return false


# region: __LOGS

static func pp_name() -> String:
	return "WorldVideoSettingSetup"

static func __LOG_B() -> bool:
	return false

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion
