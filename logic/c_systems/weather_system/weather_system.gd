@tool
class_name WeatherSystem
extends Node3DSystem


@onready var world_env: WorldEnvironment = %WorldEnvironment

@export var sun_light: DirectionalLight3D

const ENV_PARAM_AMB_LIGHT_ENERGY := "ambient_light_energy"
const ENV_PARAM_AMB_LIGHT_SKY_CONTRIBUTION := "ambient_light_sky_contribution"
const ENV_PARAM_FOG_LIGHT_COLOR := "fog_light_color"
const ENV_PARAM_VOL_FOG_LIGHT_COLOR := "volumetric_fog_albedo"
const ENV_PARAM_VOL_FOG_DENSITY := "volumetric_fog_density"
const SHADER_PARAM_SUN_SCATTER := "shader_parameter/sun_scatter"
const SHADER_PARAM_TOP_COLOR := "shader_parameter/top_color"
const SHADER_PARAM_BOTTOM_COLOR := "shader_parameter/bottom_color"
const SHADER_PARAM_CLOUD_COVERAGE := "shader_parameter/cloud_coverage"
const ENV_PARAM_DIRECT_LIGHT_ENERGY := "light_energy"

## -- Defaults --
## env
const DEF_AMB_LIGHT_ENERGY := 2.0
const DEF_AMB_LIGHT_SKY_CONTRIBUTION := 0.2
const DEF_FOG_LIGHT_COLOR := Color("415f80")
const DEF_VOL_FOG_LIGHT_COLOR := Color("c6f2ff")
const DEF_VOL_FOG_DENSITY := 0.003
## sky shader
const DEF_SHADER_SUN_SCATTER_COLOR := Color("5a95a6")
const DEF_SHADER_TOP_COLOR := Color("603579")
const DEF_SHADER_BOTTOM_COLOR := Color("06002c")
const DEF_SHADER_CLOUD_COVERAGE := 0.67
## sun light
const DEF_DIRECT_LIGHT_ENERGY := 1.0


# Tween references
var _tween_amb_light: Tween
var _tween_amb_sky_contribution: Tween
var _tween_fog_light_color: Tween
var _tween_vol_fog_light_color: Tween
var _tween_vol_fog_density: Tween
var _tween_top_color: Tween
var _tween_bottom_color: Tween
var _tween_cloud_coverage: Tween
var _tween_sun_scatter: Tween
var _tween_direct_light: Tween


func __hard_dependencies() -> Array:
	return [world_env]

func __soft_dependencies() -> Array:
	return [sun_light]


func _ready() -> void:
	if not eu.is_editor():
		if not __perform_validation():
			return
		## initialize with defaults
		restore_all_defaults(0.0)


func restore_all_defaults(time: float) -> void:
	## env
	tween_ambient_energy(DEF_AMB_LIGHT_ENERGY, time)
	tween_ambient_sky_contribution(DEF_AMB_LIGHT_SKY_CONTRIBUTION, time)
	tween_fog_light_color(DEF_FOG_LIGHT_COLOR, time)
	tween_vol_fog_light_color(DEF_VOL_FOG_LIGHT_COLOR, time)
	tween_vol_fog_density(DEF_VOL_FOG_DENSITY, time)
	## sky shader
	tween_shader_sun_scatter(DEF_SHADER_SUN_SCATTER_COLOR, time)
	tween_shader_top_color(DEF_SHADER_TOP_COLOR, time)
	tween_shader_bottom_color(DEF_SHADER_BOTTOM_COLOR, time)
	tween_shader_cloud_coverage(DEF_SHADER_CLOUD_COVERAGE, time)
	## sun light
	tween_direct_light_energy(DEF_DIRECT_LIGHT_ENERGY, time)


func tween_ambient_energy(target_val: float, time: float) -> void:
	_tween_amb_light = _start_tween(get_env(), ENV_PARAM_AMB_LIGHT_ENERGY, target_val, time, _tween_amb_light)

func tween_ambient_sky_contribution(target_val: float, time: float) -> void:
	_tween_amb_sky_contribution = _start_tween(get_env(), ENV_PARAM_AMB_LIGHT_SKY_CONTRIBUTION, target_val, time, _tween_amb_sky_contribution)

func tween_fog_light_color(target_val: Color, time: float) -> void:
	_tween_fog_light_color = _start_tween(get_env(), ENV_PARAM_FOG_LIGHT_COLOR, target_val, time, _tween_fog_light_color)

func tween_vol_fog_light_color(target_val: Color, time: float) -> void:
	_tween_vol_fog_light_color = _start_tween(get_env(), ENV_PARAM_VOL_FOG_LIGHT_COLOR, target_val, time, _tween_vol_fog_light_color)

func tween_vol_fog_density(target_val: float, time: float) -> void:
	_tween_vol_fog_density = _start_tween(get_env(), ENV_PARAM_VOL_FOG_DENSITY, target_val, time, _tween_vol_fog_density)

func tween_shader_sun_scatter(target_val: Color, time: float) -> void:
	_tween_sun_scatter = _start_tween(get_sky_mat(), SHADER_PARAM_SUN_SCATTER, target_val, time, _tween_sun_scatter)

func tween_shader_top_color(target_val: Color, time: float) -> void:
	_tween_top_color = _start_tween(get_sky_mat(), SHADER_PARAM_TOP_COLOR, target_val, time, _tween_top_color)

func tween_shader_bottom_color(target_val: Color, time: float) -> void:
	_tween_bottom_color = _start_tween(get_sky_mat(), SHADER_PARAM_BOTTOM_COLOR, target_val, time, _tween_bottom_color)

func tween_shader_cloud_coverage(target_val: float, time: float) -> void:
	_tween_cloud_coverage = _start_tween(get_sky_mat(), SHADER_PARAM_CLOUD_COVERAGE, target_val, time, _tween_cloud_coverage)

func tween_direct_light_energy(target_val: float, time: float) -> void:
	if not sun_light:
		__log_warn_soft("not sun_light")
		return
	_tween_direct_light = _start_tween(sun_light, ENV_PARAM_DIRECT_LIGHT_ENERGY, target_val, time, _tween_direct_light)


# --- Internal Generic Helper ---

func _start_tween(target_obj: Object, property: String, target_val: Variant, time: float, current_tween: Tween) -> Tween:
	if not target_obj:
		__log_warn_soft("no target_obj in _start_tween")
		return null

	var start_val
	
	if target_obj is ShaderMaterial and property.begins_with("shader_parameter/"):
		var param_name := property.trim_prefix("shader_parameter/")
		start_val = target_obj.get_shader_parameter(param_name)
	else:
		start_val = target_obj.get(property)
	
	if start_val == null:
		__log_warn_soft("property not found or is null", property)
		# We can decide to return here, or try to tween anyway if we trust the target_val
		return current_tween

	if typeof(start_val) == typeof(target_val):
		if start_val is float and is_equal_approx(start_val, target_val):
			return current_tween
		if start_val is Color and start_val.is_equal_approx(target_val):
			return current_tween
	else:
		__log_warn("trying to tween between values of different types", property,
			"Start:", typeof(start_val), "Target:", typeof(target_val))
		return current_tween
		
		
	if current_tween:
		current_tween.kill()
	
	__log_("Tweening", property, start_val, "->", target_val, "(Time: ", time, ")")

	var new_tween := create_tween()

	new_tween.tween_property(target_obj, property, target_val, time)

	return new_tween


# --- Helpers for Safe Access ---

func get_env() -> Environment:
	if world_env and world_env.environment:
		return world_env.environment
	return null


func get_sky_mat() -> Material:
	var env := get_env()
	if env and env.sky and env.sky.sky_material:
		return env.sky.sky_material
	return null


# --- Getters  ---


func get_curr_direct_light_energy() -> float:
	if not sun_light: return -1.0
	return sun_light.light_energy


func __LOG_B() -> bool:
	return false
