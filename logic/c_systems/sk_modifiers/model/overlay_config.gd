extends RefCounted
class_name OverlayConfig

class Weight:
	var global: float
	var hips: float

	func _init(global_: float = 0.5, hips_: float = -1.0) -> void:
		if hips_ == -1.0:
			hips_ = global_
		self.global = global_
		self.hips = hips_


var _weight: Weight
var _blend: BlendConfig
var _speed_scale: float
var _bone_mask: Array[int]


func _init(
	weight_: Weight = null,
	blend_: BlendConfig = null,
	speed_scale_: float = 1.0,
	bone_mask_: Array[int] = []
):
	self._weight = weight_ if weight_ != null else Weight.new()
	self._blend = blend_ if blend_ != null else BlendConfig.new()
	self._speed_scale = speed_scale_
	self._bone_mask = bone_mask_


func get_weight() -> float:
	return _weight.global

func get_hips_weight() -> float:
	return _weight.hips


func get_fade_in() -> float:
	return _blend.fade_in

func get_fade_out() -> float:
	return _blend.fade_out

func get_hold() -> float:
	return _blend.hold

func get_speed_scale() -> float:
	return _speed_scale

func get_bone_mask() -> Array[int]:
	return _bone_mask


func _to_string() -> String:
	return "OverlCfg[wg:%.1f, wh:%.1f, in:%.1f, out:%.1f, h:%.1f, spd:%.1f]" % [
		_weight.global, _weight.hips, _blend.fade_in, _blend.fade_out, _blend.hold, _speed_scale
	]
