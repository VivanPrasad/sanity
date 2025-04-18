extends Node
## Description: The multiplayer singleton.

#region **************** Constants ********************** #

const MAX_PLAYERS: int = 5
const MAX_CHANNELS: int = 10

const PORT: int = 9999
const LOCAL_IP: String = "127.0.0.1"

#endregion
#region ************ Private Variables ****************** #

var _ip: String = LOCAL_IP

var _peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

#endregion
#region ************ Public Variables ******************* #

#endregion
#region ************* Private Methods ******************* #

## Initialize function for testing purposes.
func _ready() -> void:
	print(_get_shift_value())

## Returns a code from an IP.
static func _get_code_from_ip(ip_text:String) -> String:
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
static func _get_ip_from_code(code: String) -> String:
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
static func _get_shift_value() -> int:
	var time: Dictionary = \
		Time.get_datetime_dict_from_system(true)
	var shift_value: int = \
		abs(time["year"] - time["day"] + \
			time["month"] - time["hour"])
	return shift_value

## Host a multiplayer game.
func _host_game() -> void:
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var result: int = upnp.discover()
	_ip = upnp.query_external_address()
	
	#$"/root/Game".code_label.text = get_code_from_ip(ip)
	if result != OK:
		push_error("Multi::host_game() >> Not discovered")
		push_error(error_string(result))
		return
	
	if upnp.get_gateway() and upnp.get_gateway()\
			.is_valid_gateway():
		var desc: Variant = ProjectSettings.get_setting(
				"application/config/name")
		upnp.add_port_mapping(PORT, PORT, desc, "UDP")
		upnp.add_port_mapping(PORT, PORT, desc, "TCP")
	else:
		push_error(
			"Multi::host_game() >> Unable to get gateway")
		return
	print("Server ready!")
	
	_peer.create_server(PORT,MAX_PLAYERS,MAX_CHANNELS)
	multiplayer.multiplayer_peer = _peer
	#multiplayer.peer_connected.connect($"/root/Game".add_player)
	#$"/root/Game".add_player()

## Join a multiplayer game from an ip_code.
func _join_game(ip_code: String) -> void:
	_ip = _get_ip_from_code(ip_code)
	_peer.create_client(_ip,PORT)
	multiplayer.multiplayer_peer = _peer

#endregion
#region ************* Public Methods ******************** #

## Checks whether the multiplayer peer is active (online).
func is_online() -> bool:
	return bool(multiplayer.multiplayer_peer != null)

## Retrieves the minutes left before the next hour.
static func get_code_expiry() -> int:
	var time: Dictionary = \
		Time.get_datetime_dict_from_system(true)
	var mins: int = 60 - time["minute"]
	return mins
#endregion
