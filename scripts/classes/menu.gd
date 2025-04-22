class_name Menu extends Node
## The base Menu class. [br]
## Contains abstraction for opening and closing menu using a
## Stack data structure.

#region *************** References ********************** #

## All menus, referenced with current tabs (Menu enum).
@export var menu_tabs: TabContainer

## The menu particles emitted from the bottom of the screen.
@export var particles: GPUParticles2D
 
#endregion
#region **************** Constants ********************** #

const FADE_TIME: float = 0.1 ## Menu tween time for transitions

const SCALE: Vector2 = Vector2.ONE ## Menu default scale.
const MAX_SCALE: Vector2 = 1.3*SCALE ## Menu maximum scale (zoomed out).
const MIN_SCALE: Vector2 = 0.7*SCALE ## Menu maximum scale (zoomed in).

#endregion
#region ************ Private Variables ****************** #

var _tween_scale: Tween ## Zooms in/out on menu transitions
var _tween_modulate: Tween ## Fades in/out on menu transitions

## The current menu stack, with the first (front) element 
## being the current menu.
var _menu_stack: Array[int] = []

var _menu_names: Array[StringName] = []
#endregion
#region ************ Public Variables ******************* #

#endregion
#region ************* Private Methods ******************* #

## Loads all tabs as menus in menu_tabs in _menus array. 
func _load_menus() -> void:
	for node: Node in menu_tabs.get_children():
		_menu_names.append(node.name)
	
## Interface to be implemented. Must call super._ready().
func _ready() -> void:
	_load_menus()

## Stops current tweens for a new tween animation.
func _stop_tweens() -> void:
	_tween_scale = create_tween()
	_tween_modulate = create_tween()

## Transitions to the next menu. True when entering
## a new menu. False when exiting to an old menu.
func _menu_fade(enter: bool) -> void:
	var start_scale: Vector2 = MIN_SCALE if enter else MAX_SCALE
	_stop_tweens()
	_tween_scale.tween_property(
		menu_tabs,^"scale",SCALE,FADE_TIME).from(start_scale)
	_tween_modulate.tween_property(
		menu_tabs,^"modulate:a",1,FADE_TIME).from(0)

#endregion
#region ************* Public Methods ******************** #

## Retrieves the current menu's name.
func get_menu() -> StringName:
	return _menu_names[_menu_stack.front()]

## Changes the current menu to the given menu name.
func open_menu(menu_name: StringName) -> int:
	var id: int = _menu_names.find(menu_name)
	_menu_stack.push_front(id)
	menu_tabs.set_current_tab(id)
	_menu_fade(true)
	return id

## Pops the top of the menu stack and opens the previous menu.
func close_menu() -> int:
	_menu_stack.pop_front() # Pop the top menu
	var id: int = _menu_stack.front() # Get the top
	menu_tabs.set_current_tab(id) # Open last menu
	_menu_fade(false)
	return id

func change_menu(menu_name: StringName) -> int:
	close_menu()
	return open_menu(menu_name)

#endregion
