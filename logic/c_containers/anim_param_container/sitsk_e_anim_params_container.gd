class_name ESitSkAnimParamsContainer
extends BaseAnimParamsContainer


# if no track
const DEFAULT_PARAMS: Dictionary[String, bool] = {
	VULNERABLE: true,
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
	"../../../../../AnimatorManager/NativePlayer/AnimParameters",
	"%AnimParameters:",
	"%GeneralSkeleton/../../../../AnimatorManager/NativePlayer/AnimParameters:",
	"%GeneralSkeleton/../../../../../AnimatorManager/NativePlayer/AnimParameters:",
	"%GeneralSkeleton/../../../AnimatorManager/NativePlayer/AnimParameters:",
	"../../../../../AnimatorManager/NativePlayer/AnimParameters:",
	"AnimatorManager/NativePlayer/AnimParameters:",
	]

#####################

	
func is_weapon_hurts(weapon_name: String, anim: Animation, timestamp: float) -> bool:
	match weapon_name:
		WeaponID.bg_aura_weapon:
			return _is_aura_hurts(anim, timestamp)
		_:
			return false


func _is_aura_hurts(anim: Animation, timestamp: float) -> bool:
	return _get_value_from_track(anim, AURA_HURTS, timestamp)
