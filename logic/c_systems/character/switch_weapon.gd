extends NodeLogger
class_name WeaponSwitcher


var _player: Princess
var _combat: PlayerCombat

# hard coded
var weapon_cycle := Cycler.new([WeaponID.smith_sword, WeaponID.small_pinga_blade], 0)


var can_switch: bool = true
var switch_dur := 0.5
var switch_overlay_weight := 0.4
var switch_bone_mask := BoneMask.get_right_arm_with_spine_and_head()
var fade_in := 0.1
var fade_out := 0.20
var speed_scale := 1.8


func initialise(player_: Princess, combat_: PlayerCombat):
	self._player = player_
	self._combat = combat_


func switch_weapon() -> void:
	if get_player().is_in_attack_state():
		u.safe_emit(get_player().switch_weapon_cant_be_done, {})
		return
	if not can_switch:
		__log_("switch_weapon", "not can_switch")
		return

	var weapon_id: String = weapon_cycle.get_next()

	__log_("switch_weapon", weapon_id)
	can_switch = false
	_start_switch_overlay()

	u.safe_emit(get_player()._sig_container.get_by_sig_id(SignalID.sfx_switch_weapon), {SFXConstants.weapon_id_key: weapon_id})

	# TODO: get switch_dur using animation markers (already are working inside overlay modifer). 
	#  			and use another marker instead of switch_dur / 2.0
	get_tree().create_timer(switch_dur / 2.0).timeout.connect(_on_middle_switch.bind(weapon_id))
	get_tree().create_timer(switch_dur).timeout.connect(func(): can_switch = true)


func _on_middle_switch(weapon_id: String):
	__log_("_on_middle_switch")
	if get_combat():
		get_combat().activate_weapon(weapon_id, true)


func _start_switch_overlay():
	__log_("_start_switch_overlay")
	var overlay_config := OverlayConfig.new(
		OverlayConfig.Weight.new(switch_overlay_weight, switch_overlay_weight / 2),
		BlendConfig.new(fade_in, fade_out),
		speed_scale,
		switch_bone_mask
		)

	get_player().animator_manager.set_overlay_anim(A.equip.equip, overlay_config)


func get_player() -> Princess:
	return _player


func get_combat() -> PlayerCombat:
	return _combat


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.switch_weapon):
		if get_player().acquired_second_weapon:
			switch_weapon()
		else:
			u.safe_emit(get_player().switch_weapon_cant_be_done, {})

	## DEV			
	# switch_overlay_weight = u._dev_change_t12_param(event, switch_overlay_weight, "switch_overlay_weight", 0.05)
	# fade_in = u._dev_change_t34_param(event, fade_in, "fade_in", 0.05)
	# fade_out = u._dev_change_t67_param(event, fade_out, "fade_out", 0.05)


## DEV
# var cycle_masks = Cycler.new([
# 	BoneMask.get_right_arm_full(),
# 	BoneMask.get_right_arm_with_spine(),
# 	BoneMask.get_right_arm_with_upper_chest(),
# 	BoneMask.get_right_arm_with_spine_and_head(),
# 	BoneMask.get_right_arm_with_spine_and_left_shoulder(),
# 	])


func pp_name() -> String:
	return "⚔️⇆"
