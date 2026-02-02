class_name MFAnimParamsContainer
extends BaseAnimParamsContainer


@export var parameters: MechFAnimParameters


# if no track
const DEFAULT_PARAMS: Dictionary[String, bool] = {
	INVINCIBLE: false,
	WEAPON_HURTS: false
}


func get_all_params() -> Array[String]:
	# print_.note(false, "get_all_params", DEFAULT_PARAMS.keys())
	return TypeCast.array_of_string(DEFAULT_PARAMS.keys())


func get_default_params() -> Dictionary[String, bool]:
	return DEFAULT_PARAMS


func get_track_prefixes() -> Array[String]:
	return TRACK_PREFIXES


const TRACK_PREFIXES: Array[String] = [
	"AnimationPlayer/AnimParameters:"
	]

#####################

	
func is_weapon_hurts(weapon_name: String, anim: Animation, timestamp: float) -> bool:
	match weapon_name:
		WeaponID.fighter_h_arm, WeaponID.fighter_v_arm:
			## trying simplier approach with mech fighter
			return parameters.weapon_hurts
		_:
			return false
