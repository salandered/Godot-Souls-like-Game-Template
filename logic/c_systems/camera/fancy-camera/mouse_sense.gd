class_name MouseSense
extends RefCountedLogger


var x_sense: float
var y_sense: float
var locked_y_sense: float


var _x_sense_mm := FMinMax.new(0.2, 4.0)
var _y_sense_mm := FMinMax.new(0.2, 4.0)
var _locked_y_sense_mm := FMinMax.new(0.2, 4.0)


func calculate(
	def_x_sense: float,
	def_y_sense: float,
	def_locked_y_sense_mult: float,
	x_sense_setting: float,
	y_sense_setting: float,
):
	x_sense = def_x_sense + x_sense_setting - 1
	y_sense = def_x_sense + y_sense_setting - 1
	locked_y_sense = y_sense * def_locked_y_sense_mult

	_x_sense_mm.clamp(x_sense, true, pp_name())
	_y_sense_mm.clamp(y_sense, true, pp_name())
	_locked_y_sense_mm.clamp(locked_y_sense, true, pp_name())

	__log_("calculated", self)


func _to_string() -> String:
	return pp.s("x_sense/y_sense/locked_y_sense", x_sense, y_sense, locked_y_sense)