## Reference: Player's version
class_name BigGuyAnimParamsContainer
extends BaseAnimParamsContainer


# if no track
const DEFAULT_PARAMS: Dictionary[String, bool] = {
	INVINCIBLE: false,
	WEAPON_HURTS: false,
	AURA_HURTS: false
}


func get_all_params() -> Array[String]:
	# print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return TypeCast.array_of_string(DEFAULT_PARAMS.keys())


func get_default_params() -> Dictionary[String, bool]:
	return DEFAULT_PARAMS


func get_track_prefixes() -> Array[String]:
	return TRACK_PREFIXES


const TRACK_PREFIXES: Array[String] = [
	"AnimatorManager/AnimationPlayer/AnimParameters:",
	"AnimatorManager/NativePlayer/AnimParameters:",
	"%AnimParameters:",
]
# AnimatorManager/AnimationPlayer/AnimParameters:weapon_hurts

#####################

	
func is_weapon_hurts(weapon_id: StringName, anim: Animation, timestamp: float) -> bool:
	match weapon_id:
		WeaponID.big_pinga_blade:
			return _is_weapon_hurts(anim, timestamp)
		WeaponID.bg_aura_weapon:
			return _is_aura_hurts(anim, timestamp)
		_:
			__log_warn("unknown weapon name " + pp.in_q(weapon_id), "is_weapon_hurts", "return false")
			return false


func _is_weapon_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, WEAPON_HURTS, timestamp)

func _is_aura_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, AURA_HURTS, timestamp)
