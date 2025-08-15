extends LegsBehavior

var used_actions: Array[String] = [
	"sprint",
	"jog_loco_cycle",
	"jog_loco_stop",
	"idle",
]

func update(input: InputPackage, delta: float):
	choose_action(input)
	legs_sm.current_action.update(input, delta)
func choose_action(input: InputPackage):
	if legs_sm.current_action.action_name == "sprint" and legs_sm.current_action.acts_longer_than(0.6):
		switch_to("jog_loco_cycle", input)
		return
	if legs_sm.current_action.action_name == "jog_loco_cycle" and legs_sm.current_action.acts_longer_than(0.6):
		switch_to("jog_loco_stop", input)
		return
	if legs_sm.current_action.action_name == "jog_loco_stop" and legs_sm.current_action.acts_longer_than(0.6):
		switch_to("idle", input)
		return

func on_enter_behavior(input: InputPackage):
	choose_initial_action(input)

# TODO work with momentum when it will be refactored back into the system
func choose_initial_action(input: InputPackage):
	if ["sprint"].has(legs_sm.current_action.action_name):
		switch_to("sprint", input)
		return
	if ["jog_loco_start", "jog_loco_cycle"].has(legs_sm.current_action.action_name):
		switch_to("jog_loco_cycle", input)
		return
	switch_to("idle", input)
