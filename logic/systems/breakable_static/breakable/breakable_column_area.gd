extends BreakableArea
class_name BreakableColumnArea


var filter_weapon_attacking: bool = true

var filter_player_weapon: bool = false
var filter_enemy_weapon: bool = true

var filter_player_body: bool = true
var filter_enemy_body: bool = false


func on_area_entered(incoming_area: Area3D):
	# __log_("area entered with", incoming_area)
	if incoming_area is WeaponHurtBox:
		# __log_("area entered with WeaponHurtBox", incoming_area)
		var _weapon_area := incoming_area as WeaponHurtBox
		var weapon: BaseWeapon = _weapon_area.base_weapon
		if not apply_weapon_filters(weapon):
			return
		__log_("survived apply_weapon_filter", incoming_area)
		
		SIG_breaking_area_entered.emit()

	elif incoming_area is CharacterHitbox:
		# __log_("area entered with CharacterHitbox", incoming_area)
		var body_area := incoming_area as CharacterHitbox
		if not apply_body_filters(body_area):
			return
		if not apply_state_filters_for_character(body_area):
			return
		__log_("survived apply_body_filters", incoming_area)
		
		SIG_breaking_area_entered.emit()


func apply_weapon_filters(weapon: BaseWeapon) -> bool:
	if not weapon.is_attacking() and filter_weapon_attacking:
		return false

	if weapon.is_player() and filter_player_weapon:
		return true
	if not weapon.is_player() and filter_enemy_weapon:
		return true

	return false


func apply_body_filters(body_area: CharacterHitbox) -> bool:
	if body_area.is_player() and filter_player_body:
		return true
	if not body_area.is_player() and filter_enemy_body:
		return true
	return false


func apply_state_filters_for_character(body_area: CharacterHitbox) -> bool:
	if not body_area.is_player():
		return false

	# non nullable
	var player := body_area.combat.get_character()
	
	# nullable 
	var _curr_state := player.get_current_state()
	
	if not _curr_state:
		return false

	if not _curr_state.state_name in [PS.thrown, PS.pushback]:
		return false

	__log_("caught player in thrown/pushback states")

	return true


# ## __LOGS
# # region

func pp_name() -> String:
	return "BreakableColumnArea"

func __LOG_B() -> bool:
	return false

func __LOG_INDENT() -> int:
	return 0

# # endregion
