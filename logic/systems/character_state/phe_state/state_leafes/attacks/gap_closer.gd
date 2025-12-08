extends BasePHEAttack


var gap_calculator: GapJumpCalculator

var mode_switcher: ActionModeSwitcher

const USUAL = "usual"
const POWER = "power"


func initialise_implementation():
	default_sp.ANGULAR_SPEED = 1.0
	sp_config = SpeedConfig.new(default_sp)
	
	# here speed is strength_mult_ for gap_calculator
	## note: was another gap closer for USUAL but it doesnt fit. Lets just jump
	var usual_preset := ActionModeSwitcher.Preset.new(USUAL, 0.15, PHEA.loco.jump_towards)
	var power_preset := ActionModeSwitcher.Preset.new(POWER, 1.0, PHEA.attack.power_gap_closer)
	
	mode_switcher = ActionModeSwitcher.new(usual_preset, power_preset)

	hit_damage = 35


func get_active_weapon_names() -> Array[String]:
	return [WeaponNames.big_pinga_blade, WeaponNames.bg_aura_weapon]


func _decide_mode_on_enter():
	if not me.angry_raised:
		mode_switcher.set_mode(USUAL)
	else:
		mode_switcher.set_mode(POWER)
	
	__log_ent("Mode decided:", mode_switcher.get_curr_mode_name())


func on_enter_state() -> void:
	_combat_set_hit_data_to_all_weapons()

	_decide_mode_on_enter()
	gap_calculator = GapJumpCalculator.new(mode_switcher.get_curr_speed())
	gap_calculator.set_coef(distance_to_player(), me.angry_raised)
	
	anim = anim_container.get_by_anim_id(mode_switcher.get_curr_anim_id())
	
	__log_ent("Mode:", mode_switcher.get_curr_mode_name(), "Gap config", gap_calculator.__log_(distance_to_player(), me.angry_raised))


func on_exit_state() -> void:
	APPLY_GRAVITY = true
	_pushed_rigid_bodies = false
	_combat_reset_all_weapons()


var _pushed_rigid_bodies: bool = false


func update(delta):
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
		APPLY_GRAVITY = true
		e_movement.move_with_root(delta)


	if not _pushed_rigid_bodies and passed_marker(MarkerName.PUSH_ITEMS_AROUND):
		PushRigidBodies.push_nearby_rigid_bodies(me, 3.5, 50)
		_pushed_rigid_bodies = true

	_combat_update_is_attacking()