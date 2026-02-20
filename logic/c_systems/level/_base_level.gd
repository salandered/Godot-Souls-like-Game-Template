@tool
@icon("res://-assets-/x_icons/level/icon_level_red.png")

@abstract
class_name BaseLevel
extends Node3DSystem


@export_category("Level Music")
@export var level_music_tracks: Array[AudioStream]
@export var first_track_to_play_idx: int = -1
@export var music_volume_db: float = -10.0


@export_category("Nodes to validate")
@export var is_pause_menu_controller: bool = true
@export var is_world_environment: bool = true
@export var is_base_asp: bool = true
@export var is_vibe_asp: bool = true
@export var is_background_music: bool = false


@export_category("Dev Visuals")
@export var initialise_dv: bool = false


var _bg_music_system: BackgroundMusicSystem
var base_asp: AudioStreamPlayer
var vibe_asp: AudioStreamPlayer

var _world_env: WorldEnvironment


var fog_volumes_in_scene: Array[FogVolume] = []
var direct_lights_in_scene: Array[DirectionalLight3D] = []

var enemies: Array[PHCharacter]


@abstract func basic_tonemap_exposure() -> float


@abstract func tonemap_exposure_no_vol_fog_compensation() -> float


@abstract func initialise() -> void


func __soft_validation() -> bool:
	var _r := true

	if is_base_asp:
		_r = _r and base_asp
	if is_vibe_asp:
		_r = _r and vibe_asp
	if is_background_music:
		_r = _r and _bg_music_system

	return _r


func _ready() -> void:
	if u.is_editor():
		return
	_init_delay_logic()
	add_to_group(Groups.Environment_.LEVEL)

	if initialise_dv:
		Groups.get_dv(self )
	if is_pause_menu_controller: ## easier here than in __soft_validation
		_validate_pause_menu_controller_on_init()
	if is_world_environment: ## easier here than in __soft_validation
		_setup_world_env()

		## WARNING: currently use only visible objects
		## E.g.: If game logic would make volume visible later, this would bypass the setting
		fog_volumes_in_scene = get_descendants.fog_volumes(self , true)
		direct_lights_in_scene = get_descendants.directional_lights_3d(self , true)

		update_video_settings()

	SigUtils.safe_connect(GlobalSignal.SIG_update_video_settings_for_level, _on_update_video_settings)
	

	if is_base_asp:
		base_asp = %base_asp
		if base_asp:
			base_asp.bus = BusID._TRACK_BASE
			base_asp.play()

	if is_vibe_asp:
		_setup_vibe_asp()

	if is_background_music:
		_setup_bg_music()

	initialise()

	__perform_validation()


func _init_delay_logic():
	if not initialise_dv:
		return
	if u.is_release():
		return

	await FrameUtils.wait_process_frames(3)
	
	var dvs := Groups.get_dv(self )
	__log_("goint to initalise", len(dvs), "DV nodes")
	for dv in dvs:
		if (dv is BaseDVCDependentNode or dv is BaseDVCDependentNode3D) \
			and ObjUtils.safe_has_method(dv, "initialise"):
			dv.initialise()


func _setup_vibe_asp():
	enemies = get_descendants.enemy_characters(self )
	__log_("found", len(enemies), "enemies on level")
	var player := get_descendants.one_princess(self )
	for e in enemies:
		if player:
			e.player = player
		SigUtils.safe_connect(e.SIG_angry_raised, _on_ph_enemy_sig_angry_raised)
		SigUtils.safe_connect(e.SIG_death_raised, _on_ph_enemy_sig_death_raised)
	vibe_asp = %vibe_asp
	if vibe_asp:
		vibe_asp.bus = BusID._TRACK_VIBE


func _setup_bg_music() -> void:
	if level_music_tracks.is_empty():
		return

	_bg_music_system = BackgroundMusicSystem.new()
	_bg_music_system.name = "BackgroundMusicSystem"
	
	# pass configuration before adding to tree 
	_bg_music_system.music_tracks = level_music_tracks
	_bg_music_system.first_track_to_play_idx = first_track_to_play_idx
	_bg_music_system.base_volume_db = music_volume_db
	
	add_child(_bg_music_system) # triggers _ready


func _validate_pause_menu_controller_on_init():
	var nodes := get_descendants.pause_menu_controller(self )
	error_.empty_list(nodes, "no pause_menu_controller found in the level scene")
	if len(nodes) > 1:
		error_.warn("several pause_menu_controller found in the level scene. It's weird", "", "")


func _setup_world_env():
	var nodes := get_descendants.world_environments(self )
	if error_.empty_list(nodes, "no world_environment found in the level scene"):
		_world_env = null
		return
	if len(nodes) > 1:
		error_.warn("several world_environment found in the level scene. It's weird", "", "")
	_world_env = nodes[0]
	error_.null_object(_world_env.environment)


func update_video_settings():
	WorldVideoSettingSetup.set_world_env_volumetric_fog_from_settings(
		_world_env,
		fog_volumes_in_scene,
		basic_tonemap_exposure(),
		tonemap_exposure_no_vol_fog_compensation())
	WorldVideoSettingSetup.set_world_env_tonemap_exposure_from_settings(
		_world_env,
		basic_tonemap_exposure(),
		tonemap_exposure_no_vol_fog_compensation()
		)
	WorldVideoSettingSetup.set_shadow_mode_from_settings(direct_lights_in_scene)


## On


func _on_update_video_settings() -> void:
	update_video_settings()


func _on_ph_enemy_sig_angry_raised() -> void:
	__log_("_on_ph_enemy_sig_angry_raised")

	if vibe_asp:
		vibe_asp.play()


func _on_ph_enemy_sig_death_raised() -> void:
	__log_("_on_ph_enemy_sig_death_raised")
	var all_quiet: bool = true
	for e in enemies:
		if e.angry_raised:
			all_quiet = false
			break
	if all_quiet:
		if vibe_asp:
			vibe_asp.stop()


##


func __LOG_B() -> bool:
	return false
