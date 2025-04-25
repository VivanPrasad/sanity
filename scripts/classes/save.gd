class_name Save extends Resource
## The base Save class.
## Contains setting data, user data and achievements.

#region *************** References ********************** #

#endregion
#region **************** Constants ********************** #

const USER_PATH: String = "user://"
const SAVE_PATH: String = "user://save.tres"
const LOGO_ICON_PATH: String = "res://assets/ui/icon.png"
const CHECK_ICON_PATH: String = "res://assets/ui/check.png"
const BASE_RESOLUTION: Vector2i = Vector2i(1280,720)

const EXP_GROWTH_FACTOR: int = 5

const SETTINGS_VERSION: int = 1

#endregion
#region ***************** Classes *********************** #

class UserData extends Resource:
	@export_storage var name: String = \
		"Guest%s" % randi_range(111,999)
	@export_storage var color: Color = Color.WHITE
	@export_storage var icon: Texture2D = \
		load(LOGO_ICON_PATH) as Texture2D
	
	@export_storage var cosmetic: String = ""
	@export_storage var level: int = 1
	@export_storage var xp: int = 0
	@export_storage var coins: int = 0
	@export_storage var achievements: Dictionary[String,bool] = {
		"it_begins":false, "we_shall_go_together":false,
		"together_once_more":false, "60_seconds":false,
		"light_it_up":false, "the_farlands":false,
		"lone_survivor":false, "bunker_trinity":false,
		"this_is_a_robbery":false, "delulu_is_not_the_solulu":false,
		"im_the_bad_guy":false, "the_imposter":false,
		"feel_the_heat":false, "last_prayers":false,
		"ao_oni":false, "hardships":false}

class SettingsData extends Resource:
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
#region ************ Public Variables ******************* #

@export_storage var user: UserData = UserData.new()
@export_storage var settings: SettingsData = SettingsData.new()

#endregion
#region ************* Private Methods ******************* #

func _init() -> void:
	print("save initialized")

#endregion
#region ************* Public Methods ******************** #

## Write this Save into the save path.
func write() -> void:
	ResourceSaver.save(self, SAVE_PATH)
	print("file saved")

static func valid_user(save: Save) -> bool:
	return bool(save.get(&"user") != null)

static func valid_settings(save: Save) -> bool:
	if not save.get(&"settings"): return false
	return bool(save.settings.version == SETTINGS_VERSION)
## Checks whether a save file exists.
static func exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH, "Save")

## Loads the save from file if it exists. Otherwise, a new
## Save resource is initialized with the default params.
static func load() -> Save:
	if exists():
		print("found save...")
		var save: Save = ResourceLoader.load(SAVE_PATH,"Save")
		if not valid_user(save):
			print("invalid user data, creating new user data...")
			save.user = UserData.new()
		if not valid_settings(save):
			print("invalid settings data, creating new settings data...")
			save.settings = SettingsData.new()
		return save
	print("save not found... creating new save...")
	var new_save: Save = Save.new()
	new_save.write()
	return new_save

#endregion
