extends RefCounted
class_name LNextActionVerdict

## NOTE: Unlike other verdicts, here with legs actions we probably always want the next_action to be set
## Switching mechanism may decline it if it's the same as already playing. But we need to provide this info. 
## So no rule like "empty string means no switch".
##
var next_action: String
## dev
var comment: String

func _init(_next_action: String, _comment: String = ""):
	next_action = _next_action
	comment = _comment