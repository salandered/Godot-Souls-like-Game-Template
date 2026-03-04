@abstract
class_name ControlSystem
extends ControlLogger


# --------------------------------------------------------------------------

## VALIDATION FRAMEWORK [same for other extender systems]
## optional but recommended
# region

var __validated: bool = false


## Usually is called in functions like '_process' or public API
func __validation_ok() -> bool:
	return __validated


## Call inside the initialization of ur class (usually 'initialize' or '_ready')
## Validates dependecies using
##   - __hard_dependencies
##   - __soft_dependencies
##   - __hard_validation
##   - __soft_validation
## Returns the result of validation (true/false).
## If true, sets __validated flag.
## NOTE: returns true if soft validation failed.
func __perform_validation(process_disable_on_fail: bool = false) -> bool:
	var _r := ValidationFramework.validate_and_set_flag(self , process_disable_on_fail)
	return _r


## override for object null checks
func __hard_dependencies() -> Array:
	return []

## override for object null checks
func __soft_dependencies() -> Array:
	return []


## override for logic checks
func __hard_validation() -> bool:
	return true

## override for logic checks
func __soft_validation() -> bool:
	return true

# endregion

# --------------------------------------------------------------------------

## TEMPLATE TO PASTE

# func __hard_dependencies() -> Array:
# 	return [
#
# 	]
#
# func __soft_dependencies() -> Array:
# 	return [
#
# 	]


# func __hard_dependencies() -> Array:
# 	return super.__hard_dependencies() + [
#
# 	]
#
# func __soft_dependencies() -> Array:
# 	return super.__soft_dependencies() + [
#
# 	]