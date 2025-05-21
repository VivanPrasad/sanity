class_name GlobalSingleton extends Node
## Description: The global singleton.
## Contains save data, scene handling, and utitility methods.

#region *************** References ********************** #

#endregion
#region **************** Constants ********************** #

## All the achievement data to be displayed in the
## achievements menu. Internal data, not the save data.
## Initializes the achievement list objects.
var AchievementList: Array[Achievement] = [
	Achievement.new("start_with_sanity","Open the game for the first time.",Color.AQUA),
	Achievement.new("it_begins","Start a singleplayer game."),
	Achievement.new("we_shall_go_together","Complete a game as a survivor."),
	Achievement.new("together_once_more","Complete a multiplayer game."),
	Achievement.new("60_seconds","Win a game as a survivor."),
	Achievement.new("light_it_up","Search in a dark location."),
	Achievement.new("the_farlands","Discover all map tiles.",Color.YELLOW),
	Achievement.new("lone_survivor","Win a game as the only survivor remaining.",Color.YELLOW),
	Achievement.new("bunker_trinity","Hold all 3 bunker items at once.",Color.YELLOW),
	Achievement.new("this_is_a_robbery","Kill the merchant as a monster to obtain a cursed item.",Color.ORANGE),
	Achievement.new("delulu_is_not_the_solulu","Recover from insanity.",Color.ORANGE),
	Achievement.new("im_the_bad_guy","Win a game as a monster.",Color.ORANGE),
	Achievement.new("the_imposter","Lose a game as a survivor with the 'killer' trait.",Color.RED),
	Achievement.new("feel_the_heat","Complete a game as an infected survivor.",Color.RED),
	Achievement.new("last_prayers","Succeed on the final ritual doomsday.",Color.DARK_RED),
	Achievement.new("ao_oni","Win a game after being transformed into a monster.",Color.DARK_RED),
	Achievement.new("hardships","Win a game as the only survivor remaining in hard mode.",Color.DARK_RED)]

## The game display name.
const GAME_NAME: String = "Sanity"

#endregion
#region ***************** Classes *********************** #

## The achievement class for handling achievement data.

## The scene collection class.
class Scene:
	const TITLE: String = "res://scenes/ui/title.tscn"
	const GAME: String = "res://scenes/ui/game.tscn"
	const SETTINGS: String = "res://scenes/ui/settings.tscn"

#endregion
#region ************ Private Variables ****************** #

## The game save file.
var save: Save

#endregion
#region ************ Public Variables ******************* #

#endregion
#region ************* Private Methods ******************* #

## The main initializing function for the entire game.
func _init() -> void:
	save = Save.load()

#endregion
#region ************* Public Methods ******************** #

## Changes the main scene to a given scene_path. Returns
## a process_frame signal for reference to wait for the
## current scene to be freed (null) and processed to the
## new scene. Use this method with the await keyword.
func change_scene(scene_path: String) -> Signal:
	var packed: PackedScene = ResourceLoader.load(scene_path)
	get_tree().change_scene_to_packed(packed)
	return get_tree().tree_changed
	
## Quits the game executable without confirmation.
func quit() -> void:
	get_tree().auto_accept_quit = false
	get_tree().quit()

## Returns the timeout signal of a new timer object. The 
## timer lasts a given amount of seconds (float).
func wait(seconds: float = 1.0) -> Signal:
	return get_tree().create_timer(seconds).timeout

## Returns the finished signal of a new tween object.
## This method is an adapter for the tween_property method.
func tween(object: Object, property: NodePath,
		to: Variant, duration: float = 1.0) -> Signal:
	return create_tween().tween_property(
		object,property,to,duration).finished
#endregion
