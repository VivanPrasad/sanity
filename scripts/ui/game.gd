class_name Game extends Menu
## Description: The main game script.
## Handles all the game logic, including multiplayer and
## singleplayer game handling.

#region *************** References ********************** #
@onready var _lobby_slots: GridContainer = \
	$UI/Menus/HUD/Lobby/VBoxContainer/Slots as GridContainer
@onready var _players: Node2D = $Players as Node2D
@onready var _spawner: MultiplayerSpawner = \
	$Spawner as MultiplayerSpawner

@onready var _lobby_online_ui: Control = $UI/Menus/HUD/Lobby/Code

@onready var _lobby_code_expiry: Label = \
	$UI/Menus/HUD/Lobby/Code/VBoxContainer/CodeTimeLeft as Label
@onready var _lobby_code: Label = \
	$UI/Menus/HUD/Lobby/Code/VBoxContainer/Code as Label

#endregion
#region **************** Constants ********************** #

const HOST_ID: int = 1 ## Host peer ID
const PLAYER_SCENE: PackedScene = \
	preload("res://scenes/objects/player.tscn")

const CODE_COPY_TIME: float = 5.0 ## Lobby clipboard cooldown.

enum Difficulty {NORMAL, HARD} ### Game difficulties.

#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #

## The game difficulty, set by the host.
static var difficulty: Difficulty = Difficulty.NORMAL

#endregion
#region ************* Private Methods ******************* #

## Handles all in-game button UI.
func _on_button_pressed(button: Button) -> void:
	Audio.play_sfx(&"select",0.25,randf_range(3.3,3.6))
	match(button.name):
		&"Pause",&"Settings": open_menu(button.name)
		&"BackToTitle": Multi.log_off()
		&"CopyCode":
			DisplayServer.clipboard_set(
				Multi._get_code_from_ip(Multi._ip))
			button.set_disabled(true)
			button.text = "Copied"
			await Global.wait(CODE_COPY_TIME)
			button.set_disabled(false)
			button.text = "Copy Code"
		&"Back",&"Save": 
			close_menu()
			if (button.name == &"Save"): 
				Global.save.write()
		_: pass

## Connects all signals for UI component nodes in the tree.
func _connect_all_signals() -> void:
	for button: Button in find_children(
			"*","Button",true) as Array[Button]:
		button.pressed.connect(
			_on_button_pressed.bind(button))
		button.focus_mode = Control.FOCUS_NONE
	
	## Player spawner connections
	if Multi.is_host():
		_add_player()
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
	else:
		_spawner.spawned.connect(
			func(_node):_update_lobby_slots())

## Adds a player object with a given peer ID to the game.
func _add_player(id: int = HOST_ID) -> void:
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.name = str(id)
	_players.add_child(new_player)
	_update_lobby_slots()

## Removes a player object with a given peer ID.
func _remove_player(_id: int = HOST_ID) -> void:
	pass

## Allocate the lobby slots for newly spawned players.
func _update_lobby_slots() -> void:
	var player_count: int = _players.get_child_count()
	var player: Player = _players.get_child(
		player_count - 1)
	var lobby_slot: VBoxContainer = _lobby_slots.get_child(
		player.get_index()).get_child(0)
	var icon: TextureRect = lobby_slot.get_child(0)
	var button: Button = lobby_slot.get_child(1)
	button.set_disabled(true)
	button.set_text(player.username)
	button.set_tooltip_text(player.username)
	button.set_modulate(player.color)
	icon.set_texture(Global.save.icon)
	
	for slot in _lobby_slots.get_children():
		button = slot.get_child(0).get_child(1)
		if slot.get_index() == player_count or \
				slot.get_index() == 0:
			button.show()

## Handles which type of game is being played.
func _handle_game_mode() -> void:
	if not Multi.is_online(): 
		print("GAME: you're offline!")
		_lobby_online_ui.hide()
		set_process(false)
	elif Multi.is_host():
		print("GAME: you're a host!")
	elif Multi.is_local():
		print("GAME: you're a local client!")
		_lobby_online_ui.hide()
		set_process(false)
	else:
		print("GAME: you're an online client")
		
## Displays the lobby code and expiry text.
func _process(_delta: float) -> void:
	_lobby_code.text = Multi.get_lobby_code()
	_lobby_code_expiry.text = Multi.get_code_expiry()

## The main initializing function.
func _ready() -> void:
	super._ready()
	_connect_all_signals()
	open_menu(&"HUD")
	_handle_game_mode()
	Audio.play_bgm("the_cave",1.0,0.8)

#endregion
#region ************* Public Methods ******************** #

#endregion
