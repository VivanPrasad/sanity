class_name AudioSingleton extends Node
## Description: The audio singleton
## Audio files are located at res://assets/audio seperated
## by music, sound effects and ambience in the .mp3 format.

## BGM handler for music.
@onready var _bgm: AudioStreamPlayer = $BGM
## get_children() for all sfx.
@onready var _sfxs: Node = $SFXS

#region **************** Constants ********************** #

## Audio folder path.
const _AUDIO_PATH: String = "res://assets/audio"
## Convert to ogg later.
const _AUDIO_FORMAT: String = "ogg" 
## The audio data dictionary, containing a reference to
## [default linear volume, pitch scale] values.

## All the audio data, with a reference string name keyed to
## an array where 0: file_name, 1: volume_linear, 2: pitch_scale.
const _AUDIO_DATA: Dictionary[StringName,Array] = {
	&"bgm_title":[&"midnight_wanderer",.5,1],
	&"bgm_game":[&"the_cave",1,.8],
	&"ui_select":[&"ui_select",0.3,3.4],
	&"ui_type":[&"ui_select",0.05,4.4],
}
## SFX pitch_scale variance range.
const _SFX_PITCH_VARIANCE: float = 0.3
const _SFX_COUNT_LIMIT: int = 8 ## Arbituary SFX limiter.
#endregion
#region ************ Private Variables ****************** #
# No private variables
#endregion
#region ************ Public Variables ******************* #
# No public variables
#endregion
#region ***************** Classes *********************** #

## The SFX class for sound instancing, freed after playing.
class SFX:
	extends AudioStreamPlayer
	## Gets the random value from the SFX pitch_scale range
	## given with the interval [x - 0.3,x + 0.3].
	func _get_sfx_pitch(pitch: float) -> float:
		return randf_range(
			pitch - _SFX_PITCH_VARIANCE,
			pitch + _SFX_PITCH_VARIANCE)
	## SFX initializing function with a given sfx_name.
	func _init(sfx_name: StringName) -> void:
		self.stream = Audio._load_audio(sfx_name, &"sfx")
		@warning_ignore("unsafe_cast")
		self.volume_linear = _AUDIO_DATA[sfx_name][1] as float
		@warning_ignore("unsafe_cast")
		self.pitch_scale = _get_sfx_pitch(
			_AUDIO_DATA[sfx_name][2] as float)
		self.bus = &"SFX"
		self.autoplay = true
		self.finished.connect(queue_free)

#endregion
#region ************* Private Methods ******************* #

## Loads audio from a given audio_name and bgm/sfx/amb.
func _load_audio(audio_name: StringName, 
		type: StringName) -> AudioStreamOggVorbis:
	var file_name: String = _AUDIO_DATA[audio_name][0]
	var path: String = "%s/%s/%s.%s" % \
		[_AUDIO_PATH,type,file_name,_AUDIO_FORMAT]
	var file: AudioStreamOggVorbis = \
		ResourceLoader.load(path, "AudioStreamOggVorbis")
	if not file: return null
	return file
## Fades the bgm in over a given duration in seconds.
## Use await as this returns a finished tween signal.
func fade_bgm_in(bgm_volume: float, 
		duration: float = 1.0) -> Signal:
	return Global.tween(_bgm, ^"volume_linear",
		bgm_volume,duration)
## Fades the bgm out over a given duration in seconds.
## Use await as this returns a finished tween signal.
func fade_bgm_out(duration: float = 1.0) -> Signal:
	return Global.tween(_bgm, ^"volume_linear",0.0,duration)
	
#endregion
#region ************* Public Methods ******************** #

## Plays a bgm track from a given StringName. 
## Use await for a given fade_time. No fade_time default.
func play_bgm(bgm_name: StringName, fade_time: float = 0.0) -> void:
	_bgm.set_stream(_load_audio(bgm_name,&"bgm"))
	_bgm.volume_linear = 0.0
	_bgm.pitch_scale = _AUDIO_DATA[bgm_name][2]
	_bgm.play()
	var target_vol: float = _AUDIO_DATA[bgm_name][1]
	if fade_time: await fade_bgm_in(target_vol,fade_time)
	else: _bgm.volume_linear = target_vol
	

## Fades out the current bgm.
## Use await for a fade_time > 0.0.
func stop_bgm(fade_time: float = 0.0) -> void:
	if fade_time: await fade_bgm_out(fade_time)
	else: _bgm.stop()

## Switches BGM between BGM normal and BGM2 supression.
func set_bgm_focus(value: bool) -> void:
	if value: _bgm.set_bus(&"BGM")
	else: _bgm.set_bus(&"BGM2")

## Determines whether bgm is currently playing.
func is_bgm_playing() -> bool:
	return bool(_bgm.is_playing())

## Plays a sfx clip from a given StringName.
func play_sfx(sfx_name: StringName) -> void:
	if _sfxs.get_child_count() > _SFX_COUNT_LIMIT: return
	var sfx: SFX = SFX.new(sfx_name)
	_sfxs.add_child(sfx)

## Sets the volume of an Audio Bus (Master, BGM, SFX, AMB).
func set_bus_volume(bus_name: StringName,volume: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(
		bus_index, volume)

#endregion
