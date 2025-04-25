class_name LobbySlot extends PanelContainer
## The base LobbySlot class. [br]

#region *************** References ********************** #

@onready var _in_game_label: Label = $VBoxContainer/Icon/InGame
@onready var _button: Button = $VBoxContainer/Button as Button
@onready var _icon: TextureRect = $VBoxContainer/Icon as TextureRect
#endregion
#region **************** Constants ********************** #

const EMPTY_ICON: Texture2D = preload("res://assets/ui/empty_icon.tres")
const GAME_ICON: Texture2D = preload("res://assets/ui/icon.png")

const DEFAULT_TEXT: String = "Add Bot"

#endregion
#region ************ Private Variables ****************** #

var _player: Player = null
#endregion
#region ************ Public Variables ******************* #

#endregion
#region ************* Private Methods ******************* #

func _process(_delta: float) -> void:
	if !_player: return
	_button.text = _player.username
	_button.modulate = _player.color
	if (get_tree().current_scene as Game)._game_started:
		_in_game_label.visible = !_player.is_multiplayer_authority()
	
#endregion
#region ************* Public Methods ******************** #

func add(player: Player) -> void:
	set_process(true)
	_player = player
	_button.set_disabled(true)
	_icon.set_texture(GAME_ICON)
	_button.show()

func clear(count) -> void:
	set_process(false)
	_button.text = DEFAULT_TEXT
	_button.set_disabled(false)
	_icon.set_texture(EMPTY_ICON)
	_button.visible = get_index() < count

#endregion
