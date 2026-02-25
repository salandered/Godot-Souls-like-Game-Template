class_name CamTargetUtils
extends RefCountedStaticLogger


static func initialise_cam_target(for_whom: Node) -> EnemyCameraTarget:
	var targets := get_descendants.enemy_camera_targets(for_whom)
	if error_.empty_list(targets, "initialise_cam_target"):
		return null
	if len(targets) > 1:
		__log_warn("len(targets) > 0; suport only one", "", "first will be used")
	var _camera_target := targets[0]
	_camera_target.initialise(for_whom)
	_camera_target.make_active()
	return _camera_target
