extends GutTest

const TURN_INTENT_TIME_THRESHOLD = 0.05


# class TestDetermineTurnIntent:
# 	extends GutTest
	
# 	var gatherer: InputGatherer
	
# 	var reversing_params = ParameterFactory.named_parameters(
# 		["forward_time", "back_time", "expected_previous", "expected_target"],
# 		[
# 			[1.0, 1.0 + TURN_INTENT_TIME_THRESHOLD + 0.1, Vector2(0, -1), Vector2(0, 1)], # Forward then back
# 			[1.0 + TURN_INTENT_TIME_THRESHOLD + 0.1, 1.0, Vector2(0, 1), Vector2(0, -1)] # Back then forward
# 		]
# 	)
	
# 	var strafing_params = ParameterFactory.named_parameters(
# 		["left_time", "right_time", "expected_previous", "expected_target"],
# 		[
# 			[1.0, 1.0 + TURN_INTENT_TIME_THRESHOLD + 0.1, Vector2(-1, 0), Vector2(1, 0)], # Left then right
# 			[1.0 + TURN_INTENT_TIME_THRESHOLD + 0.1, 1.0, Vector2(1, 0), Vector2(-1, 0)] # Right then left
# 		]
# 	)
	
# 	func before_each():
# 		gatherer = autofree(InputGatherer.new())
	
# 	func test_reversing_determines_intent(params = use_parameters(reversing_params)):
# 		# given
# 		var input = InputPackage.new()
# 		input.is_reversing = true
		
# 		gatherer._forward_press_time = params.forward_time
# 		gatherer._back_press_time = params.back_time
		
# 		# when
# 		gatherer._determine_turn_intent(input)
		
# 		# then
# 		assert_true(input.turn_intent_known, "Should know turn intent when time diff is sufficient")
# 		assert_eq(input.previous_direction, params.expected_previous, "Previous direction")
# 		assert_eq(input.target_direction, params.expected_target, "Target direction")


# 	func test_reversing_does_not_determine_intent_when_time_diff_is_too_small():
# 		# given
# 		var input = InputPackage.new()
# 		input.is_reversing = true
		
# 		gatherer._forward_press_time = 1.0
# 		gatherer._back_press_time = 1.0 + TURN_INTENT_TIME_THRESHOLD - 0.01
		
# 		# when
# 		gatherer._determine_turn_intent(input)
		
# 		# then
# 		assert_false(input.turn_intent_known, "Should not know turn intent when time diff is too small")


# 	func test_strafing_determines_intent(params = use_parameters(strafing_params)):
# 		# given
# 		var input = InputPackage.new()
# 		input.is_strafing_opposite = true
		
# 		gatherer._left_press_time = params.left_time
# 		gatherer._right_press_time = params.right_time
		
# 		# when
# 		gatherer._determine_turn_intent(input)
		
# 		# then
# 		assert_true(input.turn_intent_known, "Should know turn intent for strafing")
# 		assert_eq(input.previous_direction, params.expected_previous, "Strafing previous direction")
# 		assert_eq(input.target_direction, params.expected_target, "Strafing target direction")