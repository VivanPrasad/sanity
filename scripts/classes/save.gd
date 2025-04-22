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
const CURRENT_VERSION: String = "alpha1"

enum InputMode {MOUSE, KEYBOARD}
enum Quality {LOW,NORMAL,HIGH}

#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #

@export_storage var version: String = CURRENT_VERSION
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

@export_storage var username: String = \
	"Guest%s" % randi_range(111,999)
@export_storage var color: Color = \
	Color(randf(),randf(),randf())
@export_storage var icon: Texture2D = load(LOGO_ICON_PATH) as Texture2D
@export_storage var cosmetic: String = ""
@export_storage var chat_enabled: bool = true

@export_storage var achievements: Dictionary[String,bool] = {
	"it_begins":false,
	"we_shall_go_together":false, #Complete a survivor run
	"lone_survivor":false, #Win a game as the last survivor
	"im_a_monster":false, # Play as a monster 
	"together_once_more":false, #Play multiplayer
	"light_it_up":false, #Search a dark location
	"hardships":false,
	"last_prayers":false, #Succeed on the final ritual doomsday
	"bunker_trinity":false, #Hold all 3 bunker items at once
	"merchant_affinity":false,
	"counting_stars":false, #Recover from insanity
	"delulu_is_not_the_solulu":false, #Complete a survivor run infected
	"ao_oni":false, #Transform into a monster
}

#endregion
#region ************* Private Methods ******************* #
	
#endregion
#region ************* Public Methods ******************** #

## Write this Save into the save path.
func write() -> void:
	ResourceSaver.save(self, SAVE_PATH)
	print("Save::write() >> file saved")

## Verifies that the game's version matches the save version.
static func valid() -> bool:
	if !exists(): return false
	var save: Save = ResourceLoader.load(SAVE_PATH, "Save")
	return bool(save.version == CURRENT_VERSION)

## Checks whether a save file exists.
static func exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH, "Save")

## Loads the save from file if it exists. Otherwise, a new
## Save resource is initialized with the default params.
static func load() -> Save:
	if valid():
		return ResourceLoader.load(SAVE_PATH,"Save")
	return Save.new()

#endregion
