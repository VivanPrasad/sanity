class_name Game extends Menu
## Description: The main game script.
## Handles all the game logic, including multiplayer and
## singleplayer game handling.

#region *************** References ********************** #

@onready var _lobby_slots: GridContainer = \
	$UI/Menus/Lobby/VBoxContainer/Slots as GridContainer
@onready var _players: Node2D = $Players as Node2D
@onready var _spawner: MultiplayerSpawner = \
	$Spawner as MultiplayerSpawner

@onready var _lobby_online_ui: Control = $UI/Menus/Lobby/VBoxContainer2

@onready var _lobby_code_expiry: Label = \
	$UI/Menus/Lobby/VBoxContainer2/CodeTimeLeft as Label
@onready var _lobby_code: Label = \
	$UI/Menus/Lobby/VBoxContainer2/Code as Label
	
@onready var _start_game_button: Button = \
	$UI/Menus/Lobby/StartGame as Button
@onready var spectate_game: Button = \
	$UI/Menus/Lobby/SpectateGame as Button

@onready var _countdown_label: Label = \
	$UI/Menus/Lobby/Countdown as Label
@onready var _start_game_timer: Timer = \
	$UI/Menus/Lobby/StartGameTimer as Timer

#endregion
#region **************** Constants ********************** #
## The Host peer ID (1) constant.
const HOST_ID: int = 1
## Lobby clipboard cooldown.
const CODE_COPY_TIME: float = 5.0
## Game difficulties.
enum Difficulty {NORMAL, HARD} 

const PLAYER_SCENE: PackedScene = \
	preload("res://scenes/objects/player.tscn")
const COUNTDOWN_TEXT: String = "Starting in %s"

#endregion
#region ************ Private Variables ****************** #

## The list of player peerIDs, in sync with the
## _players Node2D tree.
var _player_list: Array[int] = []
static var _game_started: bool = false
#endregion
#region ************ Public Variables ******************* #

## The game difficulty, set by the host.
static var difficulty: Difficulty = Difficulty.NORMAL

#endregion
#region ************* Private Methods ******************* #

## Starts the game countdown for all players in lobby.
## The countdown stops if players join or exit.
@rpc("authority","call_local","reliable")
func _start_game_countdown() -> void:
	print("game started for those in the lobby!")
	_countdown_label.show()
	_start_game_button.hide()
	_start_game_timer.start()

## Stops the game countdown for all players.
@rpc("authority","call_local","reliable")
func _stop_game_countdown() -> void:
	if Multi.is_host(): _start_game_button.show()
	_start_game_timer.stop()
	_countdown_label.hide()

## Commenses the game, assigns the monster role for those in the lobby.
## Players that join after this point will have to spectate.
@rpc("authority","call_local","reliable")
func _start_game() -> void:
	_game_started = true
	$UI.hide()

## Handles all in-game button UI.
func _on_button_pressed(button: Button) -> void:
	Audio.play_sfx(&"ui_select")
	match(button.name):
		&"StartGame": rpc(&"_start_game_countdown")
		&"SpectateGame": $UI.hide()
		&"Pause",&"Settings": open_menu(button.name)
		&"MainMenu": Multi.log_off()
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
	if Multi.is_host() or not Multi.is_online():
		_add_player()
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_start_game_timer.timeout.connect(
			func() -> void: rpc(&"_start_game"))
	else:
		_spawner.spawned.connect(
			func(_player: Player) -> void: _update_lobby_slots())
		_spawner.despawned.connect(
			func(_player: Player) -> void: _update_lobby_slots())

## Adds a player object with a given peer ID to the game.
func _add_player(id: int = HOST_ID) -> void:
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.name = str(id)
	_player_list.append(id)
	_players.add_child(new_player)
	_update_lobby_slots()
	rpc(&"_stop_game_countdown")

## Removes a player object with a given peer ID.
func _remove_player(id: int) -> void:
	if Multi.is_host(): 
		prints("GAME: peer",id,"disconnected!")
	var index: int = _player_list.find(id)
	var delete: Player = _players.get_child(index)
	
	if delete != null:
		delete.free()
		_player_list.remove_at(index)
	_update_lobby_slots()
	rpc(&"_stop_game_countdown")

## Allocates and deallocates lobby slots for players.
func _update_lobby_slots() -> void:
	var index: int = 0
	var count: int = get_player_count()
	for lobby_slot: PlayerSlot in _lobby_slots\
			.get_children() as Array[PlayerSlot]:
		if index > count - 1:
			lobby_slot.clear(count)
		else: 
			var player: Player = _players.get_child(index) 
			lobby_slot.add(player)
		index += 1

## Handles which type of game is being played.
func _handle_game_mode() -> void:
	if not Multi.is_online(): 
		_lobby_online_ui.hide()
		set_process(false)
	elif Multi.is_host(): pass
	elif Multi.is_local():
		_lobby_online_ui.hide()
		_start_game_button.hide()
	else:
		_start_game_button.hide()

## Displays the lobby code, expiry time, countdown start game.
func _process(_delta: float) -> void:
	_lobby_code.text = Multi.get_lobby_code()
	_lobby_code_expiry.text = Multi.get_code_expiry()
	_start_game_button.disabled = \
		_players.get_child_count() < 2
	_countdown_label.text = COUNTDOWN_TEXT %\
		ceili(_start_game_timer.time_left)

## The main initializing function.
func _ready() -> void:
	super._ready()
	_connect_all_signals()
	open_menu(&"Lobby")
	_handle_game_mode()
	Audio.play_bgm(&"bgm_game")

#endregion
#region ************* Public Methods ******************** #

## Public method wrapper for internal player node collection.
func get_player_count() -> int:
	return _players.get_child_count()
#endregion
