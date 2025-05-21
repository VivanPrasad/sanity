class_name SettingsData extends Resource
## The base SettingsData class. [br]

#region *************** References ********************** #
const SETTINGS_VERSION: int = 1
#endregion
#region **************** Constants ********************** #
const BASE_RESOLUTION: Vector2i = Vector2i(1280,720)
#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #
enum InputMode {MOUSE, KEYBOARD}
enum Quality {LOW,NORMAL,HIGH}

@export_storage var version: int = SETTINGS_VERSION
@export_storage var audio: Dictionary[StringName,float] = {
	&"Master":1.0, &"BGM":1.0, &"SFX":1.0, &"AMB":1.0} :
		set(dict):
			for key: StringName in dict as \
					Dictionary[StringName,float]:
				dict[key] = clamp(dict[key],0.0,1.0)
				var bus_index: int = \
					AudioServer.get_bus_index(key)
				AudioServer.set_bus_volume_linear(
					bus_index,dict[key])
			audio = dict

@export_storage var input_mode: InputMode = InputMode.MOUSE

@export_storage var window_mode: DisplayServer.WindowMode = \
	DisplayServer.WindowMode.WINDOW_MODE_WINDOWED

@export_storage var resolution: Vector2i = BASE_RESOLUTION
@export_storage var quality: Quality = Quality.NORMAL
@export_storage var fps: int = 60

@export_storage var chat_enabled: bool = true
#endregion
#region ************* Private Methods ******************* #

func _ready() -> void:
	pass

#endregion
#region ************* Public Methods ******************** #

#endregion
