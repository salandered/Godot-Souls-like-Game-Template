extends Resource
class_name HitData

var is_parryable: bool
var damage: float
## hit source animation (for debug purposes)
var hit_state_animation: String

var effects: Dictionary

var weapon: WeaponOh

static func blank() -> HitData:
	return HitData.new()
