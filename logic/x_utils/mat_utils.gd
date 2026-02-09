class_name MatUtils
extends RefCountedStaticLogger


class EmissionConfig:
	var emission_enabled: bool
	var use_albedo_color_for_emission: bool
	var emission_energy_mult: float
	var emission_color: Color
	## emission_color is ignored if true

	func _init(
		ee: bool = true,
		uac: bool = true,
		ec: Color = Color.ORANGE_RED,
		eem: float = 1.0,
	) -> void:
		self.emission_enabled = ee
		self.use_albedo_color_for_emission = uac
		self.emission_color = ec
		self.emission_energy_mult = eem

	func get_emission_color(albedo_color: Color) -> Color:
		return albedo_color if use_albedo_color_for_emission else emission_color


static func create_standard_3d(
	color: Color = Color.ORANGE_RED,
	shading_mode: BaseMaterial3D.ShadingMode = BaseMaterial3D.SHADING_MODE_PER_PIXEL,
	transparency: BaseMaterial3D.Transparency = BaseMaterial3D.TRANSPARENCY_DISABLED,
	no_depth_test_: bool = false,
	emission_config: EmissionConfig = null,
	cull_mode: BaseMaterial3D.CullMode = BaseMaterial3D.CULL_BACK
) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = shading_mode
	mat.transparency = transparency
	mat.no_depth_test = no_depth_test_
	mat.cull_mode = cull_mode
	
	if emission_config and emission_config.emission_enabled:
		mat.emission_enabled = true
		mat.emission = emission_config.get_emission_color(color)
		mat.emission_energy_multiplier = emission_config.emission_energy_mult
		
	return mat


# region: __LOGS

static func pp_name() -> String:
	return "MatUtils"

static func __LOG_B() -> bool:
	return true

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion
