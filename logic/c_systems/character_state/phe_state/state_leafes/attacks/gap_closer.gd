extends BasePHEAttack


var gap_calculator: GapJumpCalculator

var mode_switcher: ActionModeSwitcher

const USUAL = "usual"
const POWER = "power"

var _sfx_weapon_hit_emitted: bool = false


func initialise_implementation():
	default_sp.ANGULAR_SPEED = 1.0
	sp_config = SpeedConfig.new(default_sp)
	
	# here speed is strength_mult_ for gap_calculator
	## note: was another gap closer for USUAL but it doesnt fit. Lets just jump
	var usual_preset := ActionModeSwitcher.Preset.new(USUAL, 0.15, PHEA.loco.jump_towards)
	var power_preset := ActionModeSwitcher.Preset.new(POWER, 1.0, PHEA.attack.power_gap_closer)
	
	mode_switcher = ActionModeSwitcher.new(usual_preset, power_preset)

	hit_damage = 35


func _decide_mode_on_enter():
	if not me.angry_raised:
		mode_switcher.set_mode(USUAL)
	else:
		mode_switcher.set_mode(POWER)
	
	__log_ent("Mode decided:", mode_switcher.get_curr_mode_name())


func on_enter_state() -> void:
	_sfx_weapon_hit_emitted = false
	_combat_set_hit_data()

	_decide_mode_on_enter()
	gap_calculator = GapJumpCalculator.new(mode_switcher.get_curr_speed())
	gap_calculator.set_coef(distance_to_player(), me.angry_raised)
	
	anim = anim_container.get_by_anim_id(mode_switcher.get_curr_anim_id())
	
	__log_ent("Mode:", mode_switcher.get_curr_mode_name(), "Gap config", gap_calculator.__log_(distance_to_player(), me.angry_raised))


func on_exit_state() -> void:
	APPLY_GRAVITY = true
	_pushed_rigid_bodies = false
	_combat_reset()


var _pushed_rigid_bodies: bool = false


func update(delta: float):
	e_movement.rotate_towards_player(delta, sp_config, deg_to_rad(angle_adjustment_deg))

	if before_marker(MarkerName.JUMP.LAUNCH):
		e_movement.move_with_root(delta)
	elif before_marker(MarkerName.JUMP.LAND_START):
		var y_root_scale: bool = true
		if mode_switcher.get_curr_mode_name() == USUAL:
			APPLY_GRAVITY = false
			y_root_scale = false

		e_movement.move_with_root(delta, gap_calculator.get_curr_coef(), true, y_root_scale)
	else:
		_sfx_weapon_hit()
	
		APPLY_GRAVITY = true
		e_movement.move_with_root(delta)


	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, 3.5, 50)
		_pushed_rigid_bodies = true

	_combat_update_is_attacking()


func _sfx_weapon_hit():
	if _sfx_weapon_hit_emitted:
		return
	if combat and len(get_anim_active_weapon_ids()) > 0:
		var curr_weapon := combat.get_registered_weapon_by_id(get_anim_active_weapon_ids()[0])
		if curr_weapon:
			u.safe_emit(
				curr_weapon.get_signal_container().get_by_sig_id(SignalID.sfx_hit_weapon),
				{},
				false)
			_sfx_weapon_hit_emitted = true
