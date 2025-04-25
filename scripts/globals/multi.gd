extends Node
## Description: The multiplayer singleton.
#region *************** References ********************** #

signal thread_complete

#endregion
#region **************** Constants ********************** #

const MAX_PLAYERS: int = 5
const MAX_CHANNELS: int = 10

const PORT: int = 9999
const LOCAL_IP: String = "127.0.0.1"

const CONNECT_TIMEOUT: float = 5.0
const EXPIRY_TEXT_FORMAT: String = "Next Code in: %02d:%02d"
const LOBBY_CODE_FORMAT: String = "Lobby Code: %s"

#endregion
#region ************ Private Variables ****************** #

var _ip: String = LOCAL_IP

var ip_code_text: String = _get_code_from_ip(_ip)
var password_text: String = ""

var _peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var _create_game_thread: Thread = Thread.new() ## Host thread

#endregion
#region ************ Public Variables ******************* #

#endregion
#region ************* Private Methods ******************* #

## Returns a code from an IP.
func _get_code_from_ip(ip_text:String) -> String:
	var values = ip_text.split(".")
	var code_color : Color = Color(
		float((values[0].to_int()+_get_shift_value())/255.0),
		float((values[1].to_int()+_get_shift_value())/255.0),
		float((values[2].to_int()+_get_shift_value())/255.0),
		float((values[3].to_int()+_get_shift_value())/255.0)
	)
	var ciphered = code_color.to_html()
	return ciphered
	
## Returns IP from a code.
func _get_ip_from_code(code: String) -> String:
	var code_color: Color = Color(code.to_lower())
	var code_arr = [
		int(code_color.r*255.0-(_get_shift_value())),
		int(code_color.g*255.0-(_get_shift_value())),
		int(code_color.b*255.0-(_get_shift_value())),
		int(code_color.a*255.0-(_get_shift_value()))
	]
	var deciphered = ".".join(code_arr)
	return deciphered

## Gets a semi-unique value from time.
func _get_shift_value() -> int:
	var time: Dictionary = \
		Time.get_datetime_dict_from_system(true)
	var shift_value: int = \
		abs(time["day"] + \
			time["month"] - time["hour"])
	return shift_value

## Hosts a multiplayer game. Call this on a thread to
## prevent the game from freezing.
func _create_server() -> void:
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var result: int = upnp.discover()
	_ip = upnp.query_external_address()
	
	if result != OK:
		push_error("Multi::host_game() >> Not discovered")
		push_error(error_string(result))
		call_deferred(&"_create_server_failed")
		return
	
	if upnp.get_gateway() and upnp.get_gateway()\
			.is_valid_gateway():
		var desc: String = Global.GAME_NAME
		upnp.add_port_mapping(PORT,0, desc, "UDP")
		upnp.add_port_mapping(PORT,0, desc, "TCP")
	else:
		push_error("Multi::host_game() >> Gateway not found")
		call_deferred(&"_create_server_failed")
		return
	result = _peer.create_server(PORT,MAX_PLAYERS,MAX_CHANNELS)
	if result != OK:
		print(error_string(result))
		call_deferred(&"_create_server_failed")
		return
	print("server successfully created!")
	var ip_code: String = _get_code_from_ip(_ip)
	prints("> original:",_ip)
	prints("> retrieved:",_get_ip_from_code(ip_code))
	call_deferred(&"_create_server_success")

## Handles an unsucessful server creation.
func _create_server_failed() -> void:
	print("failed to create server")
	call_deferred(&"emit_signal",&"thread_complete")
	log_off(&"HostError")

## Handles a successful creation to a game server.
func _create_server_success() -> void:
	print("server created, joining...")
	call_deferred(&"emit_signal",&"thread_complete")
	multiplayer.multiplayer_peer = _peer
	Global.change_scene(Global.Scene.GAME)

## Handles a successful connection to a game. Joins the
## game by changing to the game scene.
func _connected_to_server() -> void:
	print("connected to server, joining...")
	Global.change_scene(Global.Scene.GAME)

## Handles when a connection to a game is unsuccessful.
## Returns to the title screen with a JoinError.
func _connection_failed() -> void:
	print("failed to connect to server")
	if Multi.is_online(): log_off(&"JoinError")

## Handles when a client from the host leaves the game.
func _peer_disconnected(id: int) -> void:
	print("peer %d disconnected!" % id)

## Handles when the host disconnects and closes the server.
func _server_disconnected() -> void:
	print("the server has been closed, disconnecting...")
	if Multi.is_online(): log_off(&"Disconnect")

## Connects all the necessary signals to their respective
## methods.
func _connect_all_signals() -> void:
	multiplayer.connected_to_server.connect(
		_connected_to_server)
	multiplayer.connection_failed.connect(
		_connection_failed)
	multiplayer.peer_disconnected.connect(
		_peer_disconnected)
	multiplayer.server_disconnected.connect(
		_server_disconnected)

## The initializing function.
func _ready() -> void:
	_connect_all_signals()

#endregion
#region ************* Public Methods ******************** #

## Retrieves the formatted expiry text before the next hour.
func get_code_expiry() -> String:
	var time: Dictionary = \
		Time.get_datetime_dict_from_system(true)
	var min_left: int = 59 - time["minute"]
	var sec_left: int = 60 - time["second"]
	return EXPIRY_TEXT_FORMAT % [min_left,sec_left]

## Retrieves the formatted lobby code to be displayed.
func get_lobby_code() -> String:
	return LOBBY_CODE_FORMAT % _get_code_from_ip(_ip)

## Checks whether the player is a host via multiplayer server.
func is_host() -> bool:
	return bool(is_online() and multiplayer.is_server())

## Checks whether the multiplayer peer is for a local connection.
func is_local() -> bool:
	return bool(is_online() and _ip == LOCAL_IP)

## Checks whether the multiplayer peer is active (online).
func is_online() -> bool:
	return bool(multiplayer.multiplayer_peer is ENetMultiplayerPeer)

## Creates a host attempt thread to enter a lobby.
func create_game() -> void:
	_create_game_thread = Thread.new()
	_create_game_thread.start(
		_create_server,Thread.PRIORITY_NORMAL)
	await thread_complete
	_create_game_thread.wait_to_finish()

## Join a multiplayer game from an ip_code.
func join_game() -> void:
	_ip = _get_ip_from_code(ip_code_text)
	if !_ip.is_valid_ip_address():
		_connection_failed(); return
	var result: int = _peer.create_client(_ip,PORT)
	if result != OK:
		_connection_failed(); return
	prints("connecting to server...",_ip)
	multiplayer.multiplayer_peer = _peer
	await Global.wait(CONNECT_TIMEOUT)
	if get_tree().current_scene is Title:
		_connection_failed()

## Join a local multiplayer game using local ip_code.
func join_local_game() -> void:
	ip_code_text = _get_code_from_ip(LOCAL_IP)
	join_game()

## Force disconnects from the game to the main menu,
## showing the type of error.
func log_off(error: StringName = &"") -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = \
		OfflineMultiplayerPeer.new()
	var main: Menu = get_tree().current_scene
	if !main is Title:
		Global.change_scene(Global.Scene.TITLE)
		await get_tree().tree_changed
		await get_tree().process_frame
		main = get_tree().current_scene
	else:
		main.close_menu()
		
	if not error.is_empty(): main.open_menu(error)

#endregion
