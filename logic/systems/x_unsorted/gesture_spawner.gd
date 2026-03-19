extends NodeLogger
class_name GestureSpawner


var _player: Princess
var _combat: PlayerCombat

# hard coded
var weapon_cycle := Cycler.new([WeaponID.smith_sword, WeaponID.small_pinga_blade], 0)

var can_switch: bool = true
var can_wave: bool = true
var switch_dur := 0.5
var wave_dur := 3.0
var switch_overlay_weight := 0.4
var wave_overlay_weight := 0.9


var switch_weapon_overlay_config = OverlayConfig.new(
		OverlayConfig.Weight.new(switch_overlay_weight, switch_overlay_weight / 2),
		BlendConfig.new(0.1, 0.20),
		1.8,
		BoneMask.get_arm_with_spine_and_head(Side.RIGHT)
		)

var wave_overlay_config = OverlayConfig.new(
		OverlayConfig.Weight.new(wave_overlay_weight, wave_overlay_weight),
		BlendConfig.new(0.6, 0.8),
		1.2,
		BoneMask.get_arm_with_upper_chest(Side.LEFT)
		)


func initialize(player_: Princess, combat_: PlayerCombat):
	self._player = player_
	self._combat = combat_


func switch_weapon() -> void:
	if get_player().is_in_attack_state():
		SigUtils.safe_emit_sig_data(get_player().switch_weapon_cant_be_done, {})
		return
	if not can_switch:
		__log_("switch_weapon", "not can_switch")
		return

	var weapon_id: StringName = weapon_cycle.get_next()

	__log_("switch_weapon", weapon_id)
	can_switch = false
	_start_anim_overlay(A.equip.equip, switch_weapon_overlay_config)

	SigUtils.safe_emit_sig_data(get_player()._sig_container.get_by_sig_id(SignalID.sfx_switch_weapon), {SFXConstants.weapon_id_key: weapon_id})

	# TODO: get switch_dur using animation markers (already are working inside overlay modifier). 
	#  			and use another marker instead of switch_dur / 2.0
	get_tree().create_timer(switch_dur / 2.0).timeout.connect(_on_middle_switch.bind(weapon_id))
	get_tree().create_timer(switch_dur).timeout.connect(func(): can_switch = true)


func wave() -> void:
	if get_player().is_in_attack_state():
		return
	if not can_wave:
		__log_("wave", "not can_wave")
		return

	can_wave = false
	_start_anim_overlay(A.equip.wave, wave_overlay_config)

	get_tree().create_timer(wave_dur).timeout.connect(func(): can_wave = true)
	SigUtils.safe_emit_no_payload(PlayerStats.SIG_player_waved)


func _on_middle_switch(weapon_id: StringName):
	__log_("_on_middle_switch")
	if get_combat():
		get_combat().activate_weapon(weapon_id, true)


func _start_anim_overlay(anim_id: StringName, overlay_config: OverlayConfig):
	__log_("_start_anim_overlay", anim_id)

	get_player().get_animator_manager().set_overlay_anim(
		anim_id,
		overlay_config)


func get_player() -> Princess:
	return _player


func get_combat() -> PlayerCombat:
	return _combat


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.switch_weapon):
		if get_player().acquired_second_weapon:
			switch_weapon()
		else:
			SigUtils.safe_emit_sig_data(get_player().switch_weapon_cant_be_done, {})
	if InputUtils.is_keycode(event, KEY_Y):
		if get_player():
			wave()
			InputUtils.mark_input_handled(self )

	## DEV			
	# switch_overlay_weight = InputUtils._dev_change_t12_param(event, switch_overlay_weight, "switch_overlay_weight", 0.05)
	# fade_in = InputUtils._dev_change_t34_param(event, fade_in, "fade_in", 0.05)
	# fade_out = InputUtils._dev_change_t67_param(event, fade_out, "fade_out", 0.05)


## DEV
# var cycle_masks = Cycler.new([
# 	BoneMask.get_right_arm_full(),
# 	BoneMask.get_right_arm_with_spine(),
# 	BoneMask.get_right_arm_with_upper_chest(),
# 	BoneMask.get_right_arm_with_spine_and_head(),
# 	BoneMask.get_right_arm_with_spine_and_left_shoulder(),
# 	])


func __LOG_B() -> bool:
	return false
