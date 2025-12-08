extends LegsBehavior


const START_THRESHOLD := 0.25 # WARNING: have NO influence while playing with keyboard
const IDLE_COMMIT := 0.12 # seconds
const START_COMMIT := 0.2 # seconds

const STOP_RESUME_COMMIT := 0.1 # Can't resume immediately
const STOP_COMMIT := 0.15 # New: how long before can switch from stop

var TO_STOP_DELAY: float = 0.1
var _non_moving_timer: SimpleTimer = SimpleTimer.new()


var _reason: String = ""

func _ready() -> void:
	_non_moving_timer.initialise(TO_STOP_DELAY)


func choose_action(input_: InputPackage, delta: float) -> LNextActionVerdict:
	_reason = ""
	var curr_action := get_curr_action()
	var curr_action_name := get_curr_action().action_name
	var prev_action_name := get_prev_action().action_name
	var curr_motion_type := get_curr_action().motion_type
	var next_action_name := supported_actions.convert_to_supported(curr_action)

	match curr_motion_type:
		MotionType.IDLE:
			if is_moving(input_) and curr_action.works_longer_than(IDLE_COMMIT):
				next_action_name = supported_actions.default_by_motion(MotionType.START)
				_reason += pp.s("works >", "commit", IDLE_COMMIT)
	
		MotionType.START:
			if is_moving(input_):
				if curr_action.time_remaining_for_smooth_switch(supported_actions.default_by_motion(MotionType.START)) < 0.05:
					next_action_name = supported_actions.default_by_motion(MotionType.LOOP)
					_reason += "time for smooth sw < 0.05"
			else:
				if curr_action.works_longer_than(START_COMMIT):
					next_action_name = supported_actions.default_by_motion(MotionType.IDLE)
					_reason += pp.s("works >", "commit", START_COMMIT)
		
		MotionType.LOOP:
			next_action_name = _from_LOOP_decision(input_, delta, next_action_name)

		MotionType.STOP:
			if is_moving(input_):
				if curr_action.works_longer_than(STOP_RESUME_COMMIT):
					next_action_name = supported_actions.default_by_motion(MotionType.LOOP) ## could be START here
					_reason += pp.s("works >", "commit", STOP_RESUME_COMMIT)
			else:
				if curr_action.time_remaining() < 0.5: # curr_action.works_longer_than(STOP_COMMIT) and
					next_action_name = supported_actions.default_by_motion(MotionType.IDLE)
					_reason += pp.s("time_remaining >", "0.1", STOP_COMMIT)

	if next_action_name != curr_action_name:
		__log_decision_data(input_, next_action_name, _reason)
	
	return LNextActionVerdict.new(next_action_name)


func _from_LOOP_decision(input_: InputPackage, delta: float, next_action_name: String) -> String:
	if is_pure_reverse_moving(input_):
		next_action_name = supported_actions.by_name(Leg.Act.fast_turn_180)
		_reason += "is_pure_reverse_moving"
		_non_moving_timer.reset()
	
	elif is_moving(input_): # normally nothing to do but we reset a timer
		if _is_short_run():
			_reason += "short run from idle is treated as MotionType.IDLE"
			next_action_name = supported_actions.default_by_motion(MotionType.START)
		_non_moving_timer.reset()
	
	elif not is_moving(input_):
		if _non_moving_timer.update(delta): # not moving / reversing and we waited some time in such condition
			_reason += "_non_moving_timer expired"
			next_action_name = supported_actions.default_by_motion(MotionType.STOP)

	return next_action_name


func _is_short_run() -> bool:
	## specific hard coded check but its ok
	var curr_action := get_curr_action()
	var curr_action_name := get_curr_action().action_name
	var prev_action_name := get_prev_action().action_name
	
	var result := false
	result = curr_action_name == Leg.Act.run and prev_action_name == Leg.Act.idle
	result = result and curr_action.time_spent() < 0.05
	return result


var _dev_test := 0.05
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(RawAction.t1):
		_dev_test -= 0.05

	if event.is_action_pressed(RawAction.t2):
		_dev_test += 0.05
