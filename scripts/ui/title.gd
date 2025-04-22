class_name Title extends Menu
## Description: The main script handler for all title menus.
## Each menu is a tab in the main TabContainer scene. [br]
## This centralized script prioritizes simpler development
## over maintainability. This may be refactored into its
## own class with a simplified interface.

#region *************** References ********************** #

@onready var _total_achievements_label: Label = \
	$Menus/Achievements/Control/Total as Label
@onready var _join_button: Button = \
	$Menus/JoinLobby/VBoxContainer/Join as Button
@onready var _save_button: Button = \
	$Menus/EditProfile/VBoxContainer/HBoxContainer/Save as Button
@onready var _achievement_list: VBoxContainer = \
	$Menus/Achievements/VBoxContainer/ScrollContainer/VBoxContainer as VBoxContainer
@onready var outdated_save: AcceptDialog = \
	$OutdatedSave as AcceptDialog

#endregion
#region **************** Constants ********************** #

const ACHIEVEMENT_SCENE: PackedScene = \
	preload("res://scenes/ui/instances/achievement.tscn")

#endregion
#region **************** Variables ********************** #

#endregion
#region ************* Private Methods ******************* #

## Method handler for all line editors.
func _on_line_text_changed(line: LineEdit) -> void:
	Audio.play_sfx("select",0.2,4.0)
	match(line.name):
		&"SetPassword":
			if len(line.text) > 16: return
			Multi.set_password(line.text)
		&"EnterCode":
			_join_button.disabled = (len(line.text) != 8 \
				or !line.text.is_valid_html_color())
			if _join_button.disabled: return
			Multi.ip_code_text = line.text
		&"EnterPassword": Multi.password_text = line.text
		&"EnterUsername":
			if (len(line.text) == 0 or len(line.text) > 16) \
					or !line.text.is_valid_ascii_identifier():
				line.set_modulate(Color.RED)
				_save_button.set_disabled(true)
				await line.editing_toggled
				line.text = Global.save.username
			_save_button.set_disabled(false)
			Global.save.username = line.text
			line.set_modulate(Color.WHITE)
		_: print("title::_on_line_text_changed() >> \
			'%s' not handled" % line.name)

## Method handler for all buttons.
func _on_button_pressed(button: Button) -> void:
	Audio.play_sfx(&"select",0.3,randf_range(3.3,3.6))
	match(button.name):
		&"Play",&"Singleplayer",&"Multiplayer",\
		&"Achievements",&"Settings",&"CreateLobby",\
		&"JoinLobby",&"Shop",&"EditProfile": 
			open_menu(button.name)
		&"NewGame": Global.change_scene(Global.Scene.GAME)
		&"Back",&"Save": 
			close_menu()
			if button.name == &"Save": Global.save.write()
		&"Host": open_menu(&"Loading"); Multi.create_game() 
		&"Join": open_menu(&"Loading"); Multi.join_game()
		&"Local": open_menu(&"Loading"); Multi.join_local_game()
		&"Exit": 
			create_tween().tween_property(
				menu_tabs,^"modulate:a",0.0,2.5)
			await create_tween().tween_property(
				Audio._bgm,^"volume_linear",0.0,4.0).finished
			Global.quit()
		_: print("title::_on_button_pressed() >> \
			'%s' not handled" % button.name)

## Configure color picker button from the Configs menu.
func _configure_color_picker(
		picker_button: ColorPickerButton) -> void:
	var picker: ColorPicker = picker_button.get_picker()
	picker.edit_alpha = false
	picker.picker_shape = ColorPicker.SHAPE_HSV_RECTANGLE
	picker.can_add_swatches = false
	picker.sampler_visible = false
	picker.color_modes_visible = false
	picker.sliders_visible = false
	picker.hex_visible = false
	picker.presets_visible = false
	picker.color_changed.connect(
		func(color: Color): Global.save.color = color)

## Connect all signals (buttons, etc.) in the title screen.
func _connect_all_signals() -> void:
	# LineEdit connections
	for line: LineEdit in find_children(
			"*","LineEdit",true) as Array[LineEdit]:
		line.text_changed.connect(
			func(_text: String): _on_line_text_changed(line))
		if line.name == &"EnterUsername": 
			line.text = Global.save.username
	
	# Button connections
	for button: Button in find_children(
			"*","Button",true) as Array[Button]:
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(
			_on_button_pressed.bind(button))
		if button.name == &"EditColor":
			var picker_button: ColorPickerButton = button as ColorPickerButton
			_configure_color_picker(picker_button)

## Populate the achievement list in the achievement menu
## with the achievement scene templates.
func _instance_achievements() -> void:
	for achievement: Global.Achievement in \
			Global.AchievementList:
		var scene:= ACHIEVEMENT_SCENE.instantiate()
		_achievement_list.add_child(scene)
		var textures: Array[Node] = scene.find_children(
			"*","TextureRect",true) as Array[Node]
		var labels: Array[Node] = scene.find_children(
			"*","Label",true) as Array[Node]
		textures[0].modulate = achievement.color
		var completed: int = 0
		if achievement.title in Global.save.achievements:
			if Global.save.achievements[achievement.title]:
				completed += 1
				textures[1].set_texture(load(Global.save.CHECK_ICON_PATH))
		labels[0].text = achievement.title.capitalize()
		labels[1].text = achievement.desc
	
		_total_achievements_label.text = "%s/%s Completed" % \
			[completed,len(Global.AchievementList)]

## Updates the particle emission and music focus.
func _update_menu_effects(id: int) -> void:
	var is_main: bool = !bool(id > 1 and id < 7)
	particles.set_emitting(is_main)
	Audio.set_bgm_focus(is_main)

## The initializing function. Starts on Main Menu with BGM.
## Also populates the achievements and shop menus.
func _ready() -> void:
	super._ready()
	_connect_all_signals()
	_instance_achievements()
	open_menu(&"Main")
	Audio.play_bgm(&"midnight_wanderer",.5)

#endregion
#region ************* Public Methods ******************** #

## Changes the current menu to the given menu name.
## Returns the id of the current menu.
func open_menu(menu_name: StringName) -> int:
	var id: int = super.open_menu(menu_name)
	_update_menu_effects(id)
	return id

## Pops the top of the menu stack and opens the previous menu.
## Returns the id of the current menu.
func close_menu() -> int:
	var id: int = super.close_menu()
	_update_menu_effects(id)
	return id

#endregion
