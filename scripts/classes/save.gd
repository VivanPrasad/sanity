class_name Save extends Resource
## The base Save class.
## Contains setting data, user data and achievements.

#region *************** References ********************** #

#endregion
#region **************** Constants ********************** #

const SAVE_PATH: String = "user://save.tres"

#endregion
#region ***************** Classes *********************** #

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
	var result: Error = ResourceSaver.save(self, SAVE_PATH)
	if result != OK:
		push_error("file not saved")
	else:
		print("file saved")
	
## Checks whether the user data is valid or not.
static func valid_user(save: Save) -> bool:
	return bool(save.get(&"user") != null)

## Checks whether the settings data is valid or not.
static func valid_settings(save: Save) -> bool:
	if not save.get(&"settings"): return false
	return bool(save.settings.version == 
		SettingsData.SETTINGS_VERSION)
	
## Checks whether a save file exists.
static func exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH, "Save")

## Loads the save from file if it exists. Otherwise, a new
## Save resource is initialized with the default params.
static func load() -> Save:
	if exists():
		print("found save...")
		var save: Save = ResourceLoader.load(SAVE_PATH)
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
