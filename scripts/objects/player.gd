class_name Player extends Node2D
## The base in-game Player class. [br]

#region *************** References ********************** #

@onready var _username: Label = $Cursor/Username
@onready var _cursor: Sprite2D = $Cursor
@onready var _camera: Camera2D = $Camera

#endregion
#region **************** Constants ********************** #
const SPAWN_POS: Vector2 = Vector2(640, 360)

const MIN_ZOOM: float = 0.4
const MAX_ZOOM: float = 1.8
const ZOOM_STEP: float = 0.2
const ZOOM_SPEED: float = 10.0

#endregion
#region ************ Private Variables ****************** #

var _zoom: float = 1.0

#endregion
#region ************ Public Variables ******************* #

var username: String = "???"
var color: Color = Color.WHITE
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
	username = Global.save.user.name
	color = Global.save.user.color
	_username.set_text(username)
	_cursor.set_modulate(color)
	_camera.set_enabled(true)
	hide()

## The initializing function.
func _ready() -> void:
	_validate_authority()

## Tracks the player's mouse position.
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_cursor.set_global_position(get_global_mouse_position())
		_camera.zoom = lerp(_camera.zoom, Vector2.ONE * _zoom,
			ZOOM_SPEED * delta)

func _process(_delta: float) -> void:
	_username.set_text(username)
	_cursor.set_modulate(color)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			position -= event.relative / _camera.zoom
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom = max(_zoom - ZOOM_STEP, MIN_ZOOM)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom = min(_zoom + ZOOM_STEP, MAX_ZOOM)

	
#endregion
#region ************* Public Methods ******************** #

#endregion
