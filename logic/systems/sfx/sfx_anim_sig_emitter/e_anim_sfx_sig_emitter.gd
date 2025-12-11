extends BaseAnimSFXSignalEmitter
class_name EnemyAnimSFXSignalEmitter


@onready var anim_manager: EnemyAnimatorManager = %AnimatorManager


func get_anim_manager() -> BaseAnimatorManager:
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
