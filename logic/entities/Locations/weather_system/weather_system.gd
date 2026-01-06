class_name WeatherSystem
extends Node3DSystem

# Global access point
static var instance: WeatherSystem

@onready var world_env: WorldEnvironment = %WorldEnvironment
## Assign your DirectionalLight3D in the Inspector
@export var sun_light: DirectionalLight3D

const SHADER_PARAM_SUN_SCATTER := "shader_parameter/sun_scatter"
const ENV_PARAM_AMB_LIGHT_ENERGY := "ambient_light_energy"
const ENV_PARAM_AMB_LIGHT_SKY_CONTRIBUTION := "ambient_light_sky_contribution"

# Defaults
const DEF_AMB_LIGHT_ENERGY := 0.2
const DEF_AMB_LIGHT_SKY_CONTRIBUTION := 0.1
const DEF_SKY_SCATTER_COLOR := Color("5a95a6")
const DEF_DIRECT_LIGHT_ENERGY := 1.0

# Tween references
var _tween_sun_scatter: Tween
var _tween_amb_light: Tween
var _tween_amb_sky_contribution: Tween
var _tween_direct_light: Tween

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null


func __hard_dependencies() -> Array[Object]:
	return [world_env]

func __soft_dependencies() -> Array[Object]:
	return [sun_light]


func _ready() -> void:
	## initialise with defaults
	if not __perform_validation():
		return
	restore_all_defaults(0.0)

# --- Public API called by Areas ---

func restore_all_defaults(time: float) -> void:
	tween_sky_scatter(DEF_SKY_SCATTER_COLOR, time)
	tween_ambient_energy(DEF_AMB_LIGHT_ENERGY, time)
	tween_ambient_sky_contribution(DEF_AMB_LIGHT_SKY_CONTRIBUTION, time)
	tween_direct_light_energy(DEF_DIRECT_LIGHT_ENERGY, time)


func tween_sky_scatter(target_val: Color, time: float) -> void:
	_tween_sun_scatter = _start_tween(get_sky_mat(), SHADER_PARAM_SUN_SCATTER, target_val, time, _tween_sun_scatter)

func tween_ambient_energy(target_val: float, time: float) -> void:
	_tween_amb_light = _start_tween(get_env(), ENV_PARAM_AMB_LIGHT_ENERGY, target_val, time, _tween_amb_light)

func tween_ambient_sky_contribution(target_val: float, time: float) -> void:
	_tween_amb_sky_contribution = _start_tween(get_env(), ENV_PARAM_AMB_LIGHT_SKY_CONTRIBUTION, target_val, time, _tween_amb_sky_contribution)

func tween_direct_light_energy(target_val: float, time: float) -> void:
	if not sun_light:
		__log_warn_soft("not sun_light")
		return
	_tween_direct_light = _start_tween(sun_light, "light_energy", target_val, time, _tween_direct_light)


# --- Internal Generic Helper ---

func _start_tween(target_obj: Object, property: String, target_val: Variant, time: float, current_tween: Tween) -> Tween:
	if not target_obj:
		__log_warn_soft("no target_obj in _start_tween")
		return null

	var start_val
	
	if target_obj is ShaderMaterial and property.begins_with("shader_parameter/"):
		var param_name = property.trim_prefix("shader_parameter/")
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

	var new_tween = create_tween()

	new_tween.tween_property(target_obj, property, target_val, time)

	return new_tween


# --- Helpers for Safe Access ---

func get_env() -> Environment:
	if world_env and world_env.environment:
		return world_env.environment
	return null


func get_sky_mat() -> Material:
	var env = get_env()
	if env and env.sky and env.sky.sky_material:
		return env.sky.sky_material
	return null


# --- Getters  ---


func get_curr_direct_light_energy() -> float:
	if not sun_light: return -1.0
	return sun_light.light_energy
