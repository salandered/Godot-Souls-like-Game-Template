class_name WeatherChangeArea
extends Area3DLogger

@export_category("Global Override")
## If true, resets all weather values to system defaults (ignores other options below)
@export var restore_to_defaults: bool = false

@export_category("Sky Scatter Color")
@export var change_sky_scatter_color: bool = false
@export var target_sky_scatter_color: Color = WeatherSystem.DEF_SKY_SCATTER_COLOR

@export_category("Ambient Light Energy")
@export var change_amb_energy: bool = false
@export var target_amb_energy: float = WeatherSystem.DEF_AMB_LIGHT_ENERGY

@export_category("Ambient Light Sky Contribution")
@export var change_amb_sky_contribution: bool = false
@export var target_amb_sky_contribution: float = WeatherSystem.DEF_AMB_LIGHT_SKY_CONTRIBUTION

@export_category("Direct Light Energy")
@export var change_direct_light: bool = false
@export var target_direct_light: float = WeatherSystem.DEF_DIRECT_LIGHT_ENERGY

@export_category("Settings")
@export var fade_time: float = 0.5


func _ready() -> void:
	collision_mask = Collision.Masks.ONLY_PLAYER
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	# Ensure 'Princess' is the correct class name for your player
	if body is Princess or body is FreeCameraBody:
		if not WeatherSystem.instance:
			__log_warn("No WeatherSystem instance found!")
			return

		__log_("Player entered weather area. Fading settings over:", fade_time)

		if restore_to_defaults:
			WeatherSystem.instance.restore_all_defaults(fade_time)
			return

		if change_sky_scatter_color:
			WeatherSystem.instance.tween_sky_scatter(target_sky_scatter_color, fade_time)
		
		if change_amb_energy:
			WeatherSystem.instance.tween_ambient_energy(target_amb_energy, fade_time)

		if change_amb_sky_contribution:
			WeatherSystem.instance.tween_ambient_sky_contribution(target_amb_sky_contribution, fade_time)
			
		if change_direct_light:
			WeatherSystem.instance.tween_direct_light_energy(target_direct_light, fade_time)
