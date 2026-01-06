@abstract
class_name CharacterBody3DSystem
extends CharacterBody3DLogger

# --------------------------------------------------------------------------

## VALIDATION FRAMEWORK [same for other extender systems]
## optional but recommended
# region

var __validated: bool = false


## Usually is called in functions like '_process' or public API
func __validation_ok() -> bool:
	return __validated


## Call inside the initialisation of ur class (usually 'initialise' or '_ready')
## Validates dependecies using
##   - __hard_dependencies
##   - __soft_dependencies
##   - __hard_validation
##   - __soft_validation
## Returns the result of validation (true/false).
## If true, sets __validated flag.
## NOTE: returns true if soft validation failed.
func __perform_validation() -> bool:
	var _r := ValidateDependencies.validate_and_set_flag(self)
	return _r


## override for object null checks
func __hard_dependencies() -> Array[Object]:
	return []

## override for object null checks
func __soft_dependencies() -> Array[Object]:
	return []


## override for logic checks
func __hard_validation() -> bool:
	return true

## override for logic checks
func __soft_validation() -> bool:
	return true

# endregion

# --------------------------------------------------------------------------
