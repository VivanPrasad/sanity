class_name Player extends Node2D
## The base in-game Player class. [br]

#region *************** References ********************** #

@onready var _label: Label = $Username
@onready var _cursor: Sprite2D = $Cursor

#endregion
#region **************** Constants ********************** #
const SPAWN_POS: Vector2 = Vector2(640,360)
#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #

var username: String
var color: Color
#endregion
#region ************* Private Methods ******************* #

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

## Configures the player if it has authority over it.
func _validate_authority() -> void:
	var authority: bool = is_multiplayer_authority()
	set_physics_process(authority)
	if !authority: return
	
	set_position(SPAWN_POS)
	username = Global.save.username
	color = Global.save.color
	_label.set_text(username)
	_cursor.set_modulate(color)
	hide()

## The initializing function.
func _ready() -> void:
	_validate_authority()
	
## Tracks the player's mouse position.
func _physics_process(_delta: float) -> void:
	set_position(get_global_mouse_position())

#endregion
#region ************* Public Methods ******************** #

#endregion
