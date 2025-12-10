class_name OnWeaponSFXSigASP
extends OnSFXSigASP


func _hard_validate_implementation():
	return self._sfx_system and self._sfx_system is BaseWeaponSFXSystem


func _custom_logic(base_vol_db: float, base_pitch: float, payload: Dictionary[String, Variant]) -> VolPitch:
	var _curr_state_name := get_holder_curr_state_name()
	if _curr_state_name in get_holder().get_power_attacks_state_names():
		base_vol_db += 4
		base_pitch -= 0.2
	
	return VolPitch.new(base_vol_db, base_pitch)


## Weapon Helpers

## not nullable
func get_weapon_sfx_system() -> BaseWeaponSFXSystem:
	return self._sfx_system as BaseWeaponSFXSystem


## not nullable
func get_weapon() -> BaseWeapon:
	var _weapon := get_weapon_sfx_system().get_weapon()
	return _weapon


## not nullable (no sfx if weapon does not have holder)
func get_holder() -> BaseCharacter:
	var _holder := get_weapon().get_holder()
	return _holder


## nullable
func get_holder_curr_state() -> BaseCharacterState:
	var _curr_state := get_holder().get_current_state()
	return _curr_state


func get_holder_curr_state_name() -> String:
	var _curr_state := get_holder().get_current_state()
	if _curr_state == null:
		return ""
	else:
		return _curr_state.state_name

func get_holder_prev_state_name() -> String:
	return get_holder().get_prev_state_name()


## __LOGS
# region

func pp_name() -> String:
	return "OnWeaponSFXSigASP"

func __LOG_B() -> bool:
	return true


func __LOG_INDENT() -> int:
	return 6

# endregion
