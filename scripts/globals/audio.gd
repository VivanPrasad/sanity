extends Node
## Description: The audio singleton

#region **************** Constants ********************** #
const _AUDIO_PATH: String = "res://assets/audio"
const _AUDIO_FORMAT: String = "mp3"

#endregion
#region ************ Private Variables ****************** #


var _bgm: AudioStreamPlayer = \
	AudioStreamPlayer.new() ### BGM handler for music
var _sfxs: Node = Node.new() ### get_children() for all sfx
#endregion
#region ************ Public Variables ******************* #

#endregion
#region ***************** Classes *********************** #

## The Music class for sound instancing.

class SFX:
	extends AudioStreamPlayer
	func _init(file_name: StringName, 
			volume: float, pitch: float) -> void:
		self.stream = Audio._load_audio(file_name,&"sfx")
		self.name = file_name
		self.volume_db += volume
		self.pitch_scale += pitch
		self.bus = &"SFX"
		self.play()
		self.finished.connect(func(): queue_free())

class AMB:
	extends AudioStreamPlayer
#endregion
#region ************* Private Methods ******************* #

## Loads audio from a given file_name and bgm/sfx/amb.
func _load_audio(file_name: StringName, 
		type: StringName) -> AudioStreamMP3:
	var path: String = "%s/%s/%s.%s" % \
		[_AUDIO_PATH,type,file_name,_AUDIO_FORMAT]
	var file: AudioStreamMP3 = \
		ResourceLoader.load(path, "AudioStreamMP3")
	if not file: return null
	return file

## Configure the Audio singleton tree.
func _configure_tree() -> void:
	_bgm.name = &"BGM"
	_bgm.bus = &"BGM"
	add_child(_bgm)
	_sfxs.name = &"SFX"
	add_child(_sfxs)
	
## Onready function.
func _ready() -> void:
	_configure_tree()

#endregion
#region ************* Public Methods ******************** #

## Plays a bgm track from a given StringName.
func play_bgm(bgm_name: StringName, 
		volume: float = 0.0, pitch: float = 1.0) -> void:
	_bgm.set_stream(_load_audio(bgm_name,&"bgm"))
	_bgm.volume_db = volume
	_bgm.pitch_scale = pitch
	_bgm.play()

## Stops the current bgm playing
func stop_bgm() -> void:
	_bgm.stop()

## Switches BGM between BGM normal and BGM2 supression
func toggle_bgm_focus() -> void:
	if _bgm.bus == &"BGM": _bgm.bus = &"BGM2"
	else: _bgm.bus = &"BGM"

## Plays a sfx clip from a given StringName.
func play_sfx(sfx_name: StringName, 
		volume: float = 0.0, pitch: float = 1.0) -> void:
	_sfxs.add_child(SFX.new(sfx_name,volume,pitch))
	
## Determines whether bgm is currently playing.
func is_bgm_playing() -> bool:
	return bool(_bgm.is_playing())

#endregion
