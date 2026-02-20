class_name MaterialUtils
extends RefCountedStaticLogger


static func create_standard_mat_3d(
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
	return "MaterialUtils"

static func __LOG_B() -> bool:
	return true

static func __log_(_prefix: Variant, ...parts: Array):
	if __LOG_B(): print_.prefix(pp.s(pp_name(), _prefix), pp.list_(parts), __LOG_INDENT())

# endregion
