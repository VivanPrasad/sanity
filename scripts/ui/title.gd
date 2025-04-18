extends Control
## Description: 

#region *************** References ********************** #

@onready var main_buttons: VBoxContainer = \
	$TabContainer/Main/MarginContainer/VBoxContainer/Buttons

@onready var multiplayer_buttons: VBoxContainer = \
	$TabContainer/Multiplayer/MarginContainer/VBoxContainer/Buttons

@onready var tabs: TabContainer = $TabContainer

#endregion
#region **************** Constants ********************** #

enum Menu {MAIN=0,NEW_GAME=1,MULTIPLAYER=2,CONFIG=3}

#endregion
#region **************** Variables ********************** #


#endregion
#region ***************** Methods *********************** #

## Returns a list of all buttons in the title screen
func _get_all_buttons() -> Array[Node]:
	return main_buttons.get_children() + \
		multiplayer_buttons.get_children()

## Method handler for all buttons
func _on_button_pressed(button: Button) -> void:
	match(button.name):
		"NewGame": 
			tabs.current_tab = Menu.NEW_GAME
			Audio.toggle_bgm_focus()
		"Multiplayer": 
			tabs.current_tab = Menu.MULTIPLAYER
			Audio.toggle_bgm_focus()
		"Config": 
			tabs.current_tab = Menu.CONFIG
			Audio.toggle_bgm_focus()
		"Back": 
			tabs.current_tab = Menu.MAIN
			Audio.toggle_bgm_focus()
		"Exit": get_tree().quit()

## Connect all buttons in the title screen
func _connect_buttons() -> void:
	for button: Button in _get_all_buttons():
		button.pressed.connect(
			_on_button_pressed.bind(button))

func _ready() -> void:
	_connect_buttons()
	Audio.play_bgm("midnight_wanderer",-5.0,1.0)

#endregion
