extends Node
class_name LegsActionsContainer

# vars
#player
#camera
#combat
#legs_sm 
#legs_anim_settings


# string action_name to LegsAction 
var actions:= { }


func get_by_name(action_name: String) -> LegsAction:
	pass


func forward_export_fields():
	pass

func build_actions_dict():
	pass 
