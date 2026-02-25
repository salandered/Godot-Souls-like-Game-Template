@tool
class_name WeatherChangeArea
extends Area3DSystem


@export_category("Dependency")
@export var weather_system: WeatherSystem = null


@export_category("Global Override")
## If true, resets all weather values to system defaults (ignores other options below)
@export var restore_to_defaults: bool = false

@export_category("Shader Sky Colors")
@export var change_sun_scatter_color: bool = false
@export var target_sun_scatter_color: Color = WeatherSystem.DEF_SHADER_SUN_SCATTER_COLOR
@export var change_top_color: bool = false
@export var target_top_color: Color = WeatherSystem.DEF_SHADER_TOP_COLOR
@export var change_bottom_color: bool = false
@export var target_bottom_color: Color = WeatherSystem.DEF_SHADER_BOTTOM_COLOR
@export var change_cloud_coverage: bool = false
@export var target_cloud_coverage: float = WeatherSystem.DEF_SHADER_CLOUD_COVERAGE

@export_category("Ambient Light")
@export var change_amb_energy: bool = false
@export var target_amb_energy: float = WeatherSystem.DEF_AMB_LIGHT_ENERGY
@export var change_amb_sky_contribution: bool = false
@export var target_amb_sky_contribution: float = WeatherSystem.DEF_AMB_LIGHT_SKY_CONTRIBUTION

@export_category("Fog")
@export var change_fog_light_color: bool = false
@export var target_fog_light_color: Color = WeatherSystem.DEF_FOG_LIGHT_COLOR
@export var change_vol_fog_light_color: bool = false
@export var target_vol_fog_light_color: Color = WeatherSystem.DEF_VOL_FOG_LIGHT_COLOR
@export var change_vol_fog_density: bool = false
@export var target_vol_fog_density: float = WeatherSystem.DEF_VOL_FOG_DENSITY

@export_category("Direct Light Energy")
@export var change_direct_light: bool = false
@export var target_direct_light: float = WeatherSystem.DEF_DIRECT_LIGHT_ENERGY

@export_category("Settings")
@export var fade_time: float = 0.5

@export_category("Dev")
@export var apply_now: bool = false:
	set(value):
		apply_now = false # reset toggle so it acts like a button
		if value and Engine.is_editor_hint():
			# call a deferred function to ensure the editor is safe/ready
			_dev_apply_settings.call_deferred()


func __hard_dependencies() -> Array:
	return [weather_system]

	
func _ready() -> void:
	if not eu.is_editor():
		if __perform_validation():
			collision_mask = Collision.Masks.ONLY_PLAYER
			body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Princess or body is FreeCameraBody:
		__log_("Player entered weather area. Fading settings over:", fade_time)

		_apply_weather_changes(weather_system, fade_time)


func _apply_weather_changes(weather_system_instance: WeatherSystem, fade_time_: float) -> void:
	if error_.null_object(weather_system_instance):
		return

	if restore_to_defaults:
		weather_system_instance.restore_all_defaults(fade_time_)
		return

	## env
	if change_amb_energy:
		weather_system_instance.tween_ambient_energy(target_amb_energy, fade_time_)
	if change_amb_sky_contribution:
		weather_system_instance.tween_ambient_sky_contribution(target_amb_sky_contribution, fade_time_)
	if change_fog_light_color:
		weather_system_instance.tween_fog_light_color(target_fog_light_color, fade_time_)
	if change_vol_fog_light_color:
		weather_system_instance.tween_vol_fog_light_color(target_vol_fog_light_color, fade_time_)
	if change_vol_fog_density:
		weather_system_instance.tween_vol_fog_density(target_vol_fog_density, fade_time_)

	## sky shader
	if change_sun_scatter_color:
		weather_system_instance.tween_shader_sun_scatter(target_sun_scatter_color, fade_time_)
	if change_top_color:
		weather_system_instance.tween_shader_top_color(target_top_color, fade_time_)
	if change_bottom_color:
		weather_system_instance.tween_shader_bottom_color(target_bottom_color, fade_time_)
	if change_cloud_coverage:
		weather_system_instance.tween_shader_cloud_coverage(target_cloud_coverage, fade_time_)
	
	## sun light
	if change_direct_light:
		weather_system_instance.tween_direct_light_energy(target_direct_light, fade_time_)


## temporary
func _on_lever_signal():
	if __perform_validation():
		_apply_weather_changes(weather_system, fade_time)

##

func _dev_apply_settings() -> void:
	if not weather_system:
		print_.dev("WeatherChangeArea", "⚠️ No WeatherSystem found. Assign it in Inspector or reload scene.")
		return

	print_.dev("WeatherChangeArea", "🛠️ Applying settings preview...")
	_apply_weather_changes(weather_system, 0.0)


##

func __LOG_B() -> bool:
	return false
