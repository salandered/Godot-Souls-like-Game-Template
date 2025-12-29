@abstract
class_name Area3DSystem
extends Area3DLogger


# --------------------------------------------------------------------------

## INITIALISATION FRAMEWORK
## optional but recommended
# region

var __initialised: bool = false


## Usually is called in functions like '_process' or public API
func __could_not_initialised() -> bool:
	return not __initialised


## Call inside your class initialisation (usually 'initialise' or '_ready')
## Validates dependecies using
##   - __hard_dependencies
##   - __soft_dependencies
##   - __hard_validate
##   - __soft_validate
## Returns the result of validation (true/false).
## If true, sets __initialised flag.
## NOTE: returns true if soft deps failed.
func __validate_dependencies() -> bool:
	var _r := ValidateDependencies.validate_and_set_init_flag(self)
	return _r


## override for object null checks
func __hard_dependencies() -> Array[Object]:
	return []

## override for object null checks
func __soft_dependencies() -> Array[Object]:
	return []


## override for logic checks
func __hard_validate() -> bool:
	return true

## override for logic checks
func __soft_validate() -> bool:
	return true

# endregion
