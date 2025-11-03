extends BasePHEComposite


var idle_for := PHEHelpers.WillDoFor.new(2.8, 6, PHEState.Leaf.combat_idle)
var pursue_for := PHEHelpers.WillDoFor.new(4, 12, PHEState.Leaf.pursue)
var orbit_for := PHEHelpers.WillDoFor.new(3, 7, PHEState.Leaf.orbit)
# var non_orbit_for := PHEHelpers.WillDoFor.new(2, 5, PHEState.Leaf.orbit)
var non_idle_for := PHEHelpers.WillDoFor.new(2, 3.5, PHEState.Leaf.combat_idle)
var not_dodge_back_for := PHEHelpers.WillNotDoFor.new(5, 7, PHEState.dodge_back_series)
var not_dodge_playful_for := PHEHelpers.WillNotDoFor.new(8, 12, PHEState.dodge_playful)
var not_jump_for := PHEHelpers.WillNotDoFor.new(4, 9, PHEState.Leaf.jump_towards)


var __monitors: Array[PHEHelpers.MonitorFor] = [
	idle_for,
	pursue_for,
	orbit_for,
	non_idle_for,
	not_dodge_back_for,
	not_dodge_playful_for,
	not_jump_for
]

var __will_do_monitors: Array[PHEHelpers.WillDoFor]


func initialise() -> void:
	__will_do_monitors = []
	for m in __monitors:
		if m is PHEHelpers.WillDoFor:
			__will_do_monitors.append(m)
				

func get_supported_substates() -> Array[String]:
	return [
			PHEState.Leaf.pursue,
			PHEState.Leaf.orbit,
			PHEState.Leaf.combat_idle,
			PHEState.Leaf.jump_towards,
			PHEState.dodge_back_series,
			PHEState.dodge_playful,
		]


func is_ended() -> bool:
	var _r: bool = true
	var _reason: String = ""
	var _current_substate := get_current_substate()
	if _current_substate == null:
		__log_upd('is_ended', "_current_substate is null. Will hard return true")
		return true

	if not _all_will_do_is_done():
		_reason += "some WillDo not done"
		_r = false
	 
	elif _current_substate.state_name in [PHEState.Leaf.jump_towards, PHEState.dodge_back_series, PHEState.dodge_playful] \
		and not _current_substate.is_ended():
		_reason += "some finite substate not ended"
		_r = false
	# just small tolerance so we can't end on first frame or something
	elif time_spent() <= 1.0:
		_reason += "works < 1.0s, give us some time"
		_r = false
	else:
		_reason += "empty else caught, by defailt we end"
	
	if _r == true:
		__log_upd("is_ended true. Reason:", _reason, "Context:", time_spent(), pp.in_q(_current_substate.state_name), _current_substate.time_remaining())
	
	return _r


func on_exit_state() -> void:
	u.reset_all(__monitors)


func check_substate_transition(delta: float, current_substate: BasePHEState, _next_state: String, _reason: String) -> VerdictPH:
	var dist := distance_to_player()

	match current_substate.state_name:
		PHEState.Leaf.pursue:
			if pursue_for.is_done():
				_reason += "pursue_for.is_done |"
				if dist > config.REAL_FAR():
					_reason += "dist > REAL_FAR"
					if not_jump_for.is_done():
						_next_state = PHEState.Leaf.jump_towards
				elif dist > config.CLOSE_TO_ORBIT():
					_reason += "dist > CLOSE_TO_ORBIT"
					if not_jump_for.is_done():
						_next_state = PHEState.Leaf.jump_towards
				elif dist > config.ORBIT_RAD():
					_reason += "dist > ORBIT_RAD"
					if not me.angry_raised:
						_next_state = ra.spick_weighted({
							PHEState.Leaf.combat_idle: 0.4,
							PHEState.Leaf.orbit: 0.6})
				elif dist > config.DODGE_RAD():
					_reason += "dist > DODGE_RAD"
					if not_dodge_playful_for.is_done():
						_next_state = PHEState.dodge_playful
					else:
						_next_state = PHEState.Leaf.combat_idle
				elif dist > config.COMBAT_RAD():
					_reason += "dist > COMBAT_RAD"
					_next_state = ra.spick_weighted({
						PHEState.Leaf.combat_idle: 0.4 if not me.angry_raised else 0.0,
						PHEState.Leaf.orbit: 0.6})
				elif dist > config.TOO_CLOSE():
					_reason += "dist > TOO_CLOSE"
					if not_dodge_back_for.is_done():
						_next_state = PHEState.dodge_back_series
				else: # too close, hard dodge
					_reason += "dist < TOO_CLOSE"
					_next_state = PHEState.dodge_back_series
			else:
				_reason += "pursue_for not done |"
				if dist < config.TOO_CLOSE():
					_next_state = PHEState.dodge_back_series
					_reason += "dist < TOO_CLOSE"
				elif dist < config.COMBAT_RAD():
					_reason += "dist < COMBAT_RAD"
					if not me.angry_raised:
						_next_state = ra.spick_weighted({
							PHEState.Leaf.combat_idle: 0.4 if not me.angry_raised else 0.0,
							PHEState.Leaf.orbit: 0.6})
				else:
					_reason += "pursue while we can"
	
		PHEState.Leaf.orbit:
			if orbit_for.is_done():
				_reason += "orbit_for.is_done |"
				if dist > config.CLOSE_TO_ORBIT() + 2:
					_next_state = PHEState.Leaf.pursue
					_reason += "dist > CLOSE_TO_ORBIT + 2"
				elif dist > config.ORBIT_RAD():
					_reason += "dist > ORBIT_RAD"
					if not_dodge_playful_for.is_done():
						_next_state = PHEState.dodge_playful
					elif ra.chance(0.4 if not me.angry_raised else 0.0):
						_next_state = PHEState.Leaf.combat_idle
				elif dist > config.COMBAT_RAD():
					_reason += "dist > COMBAT_RAD"
					if not_dodge_playful_for.is_done():
						_next_state = PHEState.dodge_playful
				elif dist > config.TOO_CLOSE():
					_reason += "dist > TOO_CLOSE"
					if not_dodge_playful_for.is_done() and ra.chance(0.5):
						_next_state = PHEState.dodge_playful
					elif not_dodge_back_for.is_done():
						_next_state = PHEState.dodge_back_series
				else: # too close, hard dodge
					_reason += "dist < TOO_CLOSE"
					_next_state = PHEState.dodge_back_series
			else: # here we look for edge cases (too far/too close)
				_reason += " orbit_for not done |"
				if dist > config.REAL_FAR() + 2:
					var _verdict := _distance_to_pursue_sbs(_next_state, _reason)
					_next_state = _verdict.next_state
					_reason += _verdict.get_reason() + ""
				elif dist < config.TOO_CLOSE():
					_next_state = PHEState.dodge_back_series
					_reason += "dist < TOO_CLOSE"
				else:
					_reason += "orbiting while we can"
		PHEState.Leaf.combat_idle:
			if idle_for.is_done():
				_reason += "idle_for.is_done |"
				var _verdict := _distance_to_pursue_sbs(_next_state, _reason)
				_next_state = _verdict.next_state
				_reason += _verdict.get_reason() + ""
			else: # (too far/too close)
				_reason += "idle_for not done |"
				if dist > config.REAL_FAR() + 3:
					var _verdict := _distance_to_pursue_sbs(_next_state, _reason)
					_next_state = _verdict.next_state
					_reason += _verdict.get_reason() + ""
				# if with not_dodge_back_for, we help player
				elif dist < config.TOO_CLOSE() and not_dodge_back_for.is_done():
					_reason += "dist < TOO_CLOSE"
					_next_state = PHEState.dodge_back_series
				else:
					_reason += "idling while we can"
	
		PHEState.dodge_back_series, PHEState.dodge_playful, PHEState.Leaf.jump_towards:
			if current_substate.is_ended():
				_reason += "dodge or jump_towards ended => _distance_to_pursue_sbs"
				var _verdict := _distance_to_pursue_sbs(_next_state, _reason)
				_next_state = _verdict.next_state
				_reason += "|" + _verdict.get_reason()
			else:
				_reason += "dodge or jump not ended"

		_:
			__log_forgot_implement(current_substate.state_name, "check_substate_transition", "_distance_to_pursue_sbs")
			var _verdict := _distance_to_pursue_sbs(_next_state, _reason)
			_next_state = _verdict.next_state
			_reason += "|" + _verdict.get_reason()

	_auto_update_monitors(__monitors, delta, current_substate.state_name, _next_state, "upd")

	return VerdictPH.new(_next_state, _reason)


func _all_will_do_is_done() -> bool:
	for monitor in __will_do_monitors:
		if not monitor.is_done():
			return false
	return true


func _distance_to_pursue_sbs(_next_state, _reason) -> VerdictPH:
	var dist := distance_to_player()
	if dist > config.REAL_FAR():
		_reason += "dist > REAL_FAR"
		_next_state = PHEState.Leaf.pursue
		if ra.chance(0.2 if not me.angry_raised else 0.4) and not_jump_for.is_done():
			_next_state = PHEState.Leaf.jump_towards
	elif dist > config.CLOSE_TO_ORBIT():
		_reason += "dist > CLOSE_TO_ORBIT"
		_next_state = PHEState.Leaf.pursue
		if ra.chance(0.2 if not me.angry_raised else 0.4) and not_jump_for.is_done():
			_next_state = PHEState.Leaf.jump_towards
		if ra.chance(0.3 if not me.angry_raised else 0.0):
			_next_state = PHEState.Leaf.combat_idle
	elif dist > config.ORBIT_RAD():
		_reason += "dist > ORBIT_RAD"
		_next_state = PHEState.Leaf.orbit
	elif dist > config.DODGE_RAD():
		_reason += "dist > DODGE_RAD"
		_next_state = PHEState.Leaf.orbit if ra.coinflip() \
			else PHEState.Leaf.combat_idle
	elif dist > config.COMBAT_RAD():
		_reason += "dist > COMBAT_RAD"
		_next_state = PHEState.Leaf.orbit if ra.coinflip() \
			else PHEState.Leaf.combat_idle
	elif dist > config.TOO_CLOSE():
		_reason += "dist > TOO_CLOSE"
		_next_state = PHEState.Leaf.orbit
	else: # too close, hard dodge
		_reason += "dist < TOO_CLOSE"
		_next_state = PHEState.dodge_back_series


	return VerdictPH.new(_next_state, _reason)


func choose_initial_substate(_next_state: String, _reason: String) -> VerdictPH:
	var _verdict := _distance_to_pursue_sbs(_next_state, _reason)
	_next_state = _verdict.next_state
	_reason += _verdict._reason

	# we set "x" as 'unknown' state. it doesnt really matter if it's not a real name
	_auto_update_monitors(__monitors, 0.0, "x", _next_state, "choose_initial_substate")
	
	return VerdictPH.new(_next_state, _reason)
