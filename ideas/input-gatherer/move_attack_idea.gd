var _to_run_attack_timer: DelayTimer = DelayTimer.new()
const MOVE_ATTACK_THRESHOLD: float = 0.1
const RUN_ATTACK_CONFIRM_DELAY: float = 0.2

## DANGER Turned OFF: i think it should be done on a state level. here it's to dangerous. 
## may be can be reused as a more abstract feature later
## handles the logic for differentiating between a standard attack and a move att
## when the light att key pressed, it checks if the player is moving
## - if player has been moving for at least MOVE_ATTACK_THRESHOLD, it starts a timer
## - if player is still moving when this timer completes, it reutrns a 'light_attack_pressed_when_move'
## - if player stops moving while the timer is running, the timer is cancelled
## - if attack key is pressed while standing, it returns a 'light_attack_pressed' instantly
# func _move_attack_feature(delta, new_input: InputPackage):
# 	## 
# 	if _to_run_attack_timer.is_initialised(): # if timer is ok we update it
# 		_to_run_attack_timer.update(delta)
		
# 		var is_still_moving := new_input.input_direction != Vector2.ZERO
		
# 		if not is_still_moving: # while timer was ok situation changed, abort
# 			_to_run_attack_timer.turn_off()
# 		elif _to_run_attack_timer.is_complete(): # Timer finished AND player is still moving
# 			new_input.combat_actions.append(CombatAction.light_attack_pressed_when_move)
# 			_to_run_attack_timer.turn_off()

# 	if _light_attack_key.is_just_pressed:
# 		if _to_run_attack_timer.is_in_progress(): # we r busy with waiting for timer
# 			pass
# 		else:
# 			var is_moving := _move_start_time > 0.0
# 			var move_duration := 0.0
# 			if is_moving:
# 				move_duration = _current_time() - _move_start_time
			
# 			if is_moving and move_duration >= MOVE_ATTACK_THRESHOLD:
# 				# start the timer which would fire the action
# 				_to_run_attack_timer.initialise(RUN_ATTACK_CONFIRM_DELAY)
# 			else:
# 				# default attack
# 				new_input.combat_actions.append(CombatAction.light_attack_pressed)