@abstract
class_name Area3DSystem
extends Area3DLogger


## INITIALISATION (OPTIONAL)
# region

var __initialised: bool = false


func __could_not_initialised() -> bool:
	return not __initialised


func __validate_deps_set_init() -> bool:
	var _r := ValidateDependencies.validate_deps_and_set_init_true(self)
	return _r


func __just_set_init_true():
	__initialised = true

func __just_set_init_false():
	__initialised = false

## returns the result of validation
## NOTE: returns true if only hard deps were met
func __validate_dependencies() -> bool:
	var _r := ValidateDependencies.validate_dependencies(self)
	return _r


func __set_initialised_true() -> bool:
	var _r := ValidateDependencies.set_initialised_true(self)
	return _r


func get_hard_dependencies() -> Array[Object]:
	return [

	]

func get_soft_dependencies() -> Array[Object]:
	return [
		
	]

# endregion
