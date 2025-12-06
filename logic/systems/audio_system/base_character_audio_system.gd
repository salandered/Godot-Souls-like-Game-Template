@abstract
class_name CharacterAudioSystem
extends BaseAudioSystem


const character_additional_data_key := "character"


@abstract func get_fs_player_3d() -> AudioStreamPlayer3D

@abstract func get_fs_scrape_player_3d() -> AudioStreamPlayer3D

@abstract func get_launch_player_3d() -> AudioStreamPlayer3D

@abstract func get_land_player_3d() -> AudioStreamPlayer3D

@abstract func get_whoosh_player_3d() -> AudioStreamPlayer3D

# @abstract func get_react_on_hit_player_3d() -> AudioStreamPlayer3D


var _character: BaseCharacter

func get_character() -> BaseCharacter:
	if not _character:
		__log_warn(true, "_character is null", "CharacterAudioSystem", "", "this should not happen")
	return _character


func create_on_signal_players(signals: BaseSignals) -> Array[OnSFXSignalPlayer]:
	return [
		## fs
		get_fs_on_signal_player(signals),
		get_fs_scrape_on_signal_player(signals),
		##
		get_launch_on_signal_player(signals),
		get_land_on_signal_player(signals),
		get_whoosh_on_signal_player(signals),
	]


## SIGNAL PACK GETTERS
## NOTE: can be overridden in subclasses 
# region

func get_fs_on_signal_player(signals: PlayerSignals) -> OnCharacterSFXFootStepSignalPlayer:
	return OnCharacterSFXFootStepSignalPlayer.new(
			self,
			signals.get_SFX_footstep(),
			get_fs_player_3d(),
			SfxType.footstep.type_name,
		)

func get_fs_scrape_on_signal_player(signals: PlayerSignals) -> OnCharacterSFXSignalPlayer:
	return OnCharacterSFXSignalPlayer.new(
			self,
			signals.get_SFX_footstep_scrape(),
			get_fs_scrape_player_3d(),
			SfxType.footstep_scrape.type_name,
		)

func get_launch_on_signal_player(signals: PlayerSignals) -> OnCharacterSFXSignalPlayer:
	return OnCharacterSFXSignalPlayer.new(
			self,
			signals.get_SFX_launch(),
			get_launch_player_3d(),
			SfxType.launch.type_name,
		)

func get_land_on_signal_player(signals: PlayerSignals) -> OnCharacterSFXSignalPlayer:
	return OnCharacterSFXSignalPlayer.new(
			self,
			signals.get_SFX_land(),
			get_land_player_3d(),
			SfxType.land.type_name,
		)

func get_whoosh_on_signal_player(signals: PlayerSignals) -> OnCharacterSFXSignalPlayer:
	return OnCharacterSFXSignalPlayer.new(
			self,
			signals.get_SFX_whoosh(),
			get_whoosh_player_3d(),
			SfxType.whoosh.type_name,
		)


func initialise_implementation(additional_data: Dictionary[String, Variant]) -> void:
	_character = u.safe_get_dict_key(additional_data, character_additional_data_key, null)

# endregion


## Character states

@abstract func get_character_run_state_name() -> String

@abstract func get_character_sprint_state_name() -> String


## __LOG


func __LOG_B() -> bool:
	return true

func __LOG_INDENT() -> int:
	return 0
