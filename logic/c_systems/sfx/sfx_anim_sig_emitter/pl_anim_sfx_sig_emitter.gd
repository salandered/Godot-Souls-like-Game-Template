extends BaseAnimSFXSignalEmitter
class_name PlayerAnimSFXSignalEmitter


@onready var anim_manager: PlAnimatorManager = %AnimatorManager


func get_animator_manager() -> BaseAnimatorManager:
	return anim_manager


## __LOG
# region

func is_player() -> bool:
	return true


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0


# endregion
