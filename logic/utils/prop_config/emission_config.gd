class_name EmissionConfig
extends RefCounted


var emission_enabled: bool
## emission_color is ignored if true
var use_albedo_color_for_emission: bool
var emission_energy_mult: float
var emission_color: Color

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
