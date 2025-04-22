extends Node
## Description: The audio singleton
## Audio files are located at res://assets/audio seperated
## by music, sound effects and ambience in the .mp3 format.

#region **************** Constants ********************** #

const _AUDIO_PATH: String = "res://assets/audio"
const _AUDIO_FORMAT: String = "ogg" ## Convert to ogg later.

const _SFX_COUNT_LIMIT: int = 8 ## Arbituary SFX limiter
#endregion
#region ************ Private Variables ****************** #

var _bgm: AudioStreamPlayer = \
	AudioStreamPlayer.new() ### BGM handler for music.
var _sfxs: Node = Node.new() ### get_children() for all sfx.

#endregion
#region ************ Public Variables ******************* #
# No public variables
#endregion
#region ***************** Classes *********************** #

## The SFX class for sound instancing, freed after playing.
class SFX:
	extends AudioStreamPlayer
	func _init(file_name: StringName, 
			volume: float, pitch: float) -> void:
		self.stream = Audio._load_audio(file_name, &"sfx")
		self.name = "%s%s" % [file_name,self.get_index()]
		self.volume_linear = volume
		self.pitch_scale = pitch
		self.bus = &"SFX"
		self.autoplay = true
		self.finished.connect(func(): queue_free())

#endregion
#region ************* Private Methods ******************* #

## Loads audio from a given file_name and bgm/sfx/amb.
func _load_audio(file_name: StringName, 
		type: StringName) -> AudioStreamOggVorbis:
	var path: String = "%s/%s/%s.%s" % \
		[_AUDIO_PATH,type,file_name,_AUDIO_FORMAT]
	var file: AudioStreamOggVorbis = \
		ResourceLoader.load(path, "AudioStreamOggVorbis")
	if not file: return null
	return file

## Configure the Audio singleton tree.
func _configure_tree() -> void:
	_bgm.set_name(&"BGM")
	_bgm.set_bus(&"BGM")
	_sfxs.set_name(&"SFX")
	add_child(_bgm)
	add_child(_sfxs)
	
## Onready function.
func _ready() -> void:
	_configure_tree()

#endregion
#region ************* Public Methods ******************** #

## Plays a bgm track from a given StringName.
func play_bgm(bgm_name: StringName, 
		volume: float = 1.0, pitch: float = 1.0) -> void:
	_bgm.set_stream(_load_audio(bgm_name,&"bgm"))
	_bgm.volume_linear = volume
	_bgm.pitch_scale = pitch
	_bgm.play()

## Stops the current bgm playing.
func stop_bgm() -> void:
	_bgm.stop()

## Switches BGM between BGM normal and BGM2 supression.
func set_bgm_focus(value: bool) -> void:
	if value: _bgm.set_bus(&"BGM")
	else: _bgm.set_bus(&"BGM2")

## Determines whether bgm is currently playing.
func is_bgm_playing() -> bool:
	return bool(_bgm.is_playing())

## Plays a sfx clip from a given StringName.
func play_sfx(sfx_name: StringName, 
		volume: float = 1.0, pitch: float = 1.0) -> void:
	if _sfxs.get_child_count() > _SFX_COUNT_LIMIT: return
	var sfx: SFX = SFX.new(sfx_name,volume,pitch)
	_sfxs.add_child(sfx)

## Sets the volume of an Audio Bus (Master, BGM, SFX, AMB).
func set_bus_volume(bus_name: StringName,volume: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(
		bus_index, volume)

#endregion
