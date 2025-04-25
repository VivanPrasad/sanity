class_name Settings extends Control
## Description: 

#region *************** References ********************** #

@onready var _settings_tabs: TabContainer = \
	$VBoxContainer/SettingsTabs as TabContainer
	
#endregion
#region **************** Constants ********************** #

enum Tab {AUDIO=0,CONTROLS,DISPLAY,SAVE_DATA}

#endregion
#region **************** Variables ********************** #

var _local_save: Save.SettingsData
var _sliders: Array[HSlider] = []
var _options: Array[OptionButton] = []

#endregion
#region ************* Private Methods ******************* #

## Method handler for all horizontal sliders.
func _on_slider_value_changed(slider: HSlider) -> void:
	match(slider.name):
		&"Master",&"BGM",&"SFX",&"AMB": 
			_local_save.audio[slider.name] = slider.value
			Audio.set_bus_volume(slider.name,slider.value)
			var value_label: Label = \
				slider.get_parent().get_child(2)
			value_label.set_text(str(int(slider.value*100)) + "%")
		_: print("title::_on_slider_changed() >> \
			'%s' not handled" % slider.name)

## Method handler for all objects inheriting the button class.
func _on_button_pressed(button: Button) -> void:
	match(button.name):
		&"Fullscreen":
			var is_fullscreen: int = 3 * int(
				button.button_pressed)
			DisplayServer.window_set_mode(is_fullscreen)
			Audio.play_sfx(&"ui_select")
		&"Back",&"Save": _on_settings_closed(
			button.name == &"Save")
		_: print("settings::_on_button_pressed() >> \
			'%s' not handled" % button.name)

## Method handler for all option buttons.
func _on_option_selected(option: OptionButton) -> void:
	match(option.name):
		&"WindowMode":
			var id: int = option.get_selected_id()
			if id == -1: return
			_local_save.window_mode = id \
				as DisplayServer.WindowMode
			DisplayServer.window_set_mode(id)

## Connects all UI signals necessary within the settings menu.
func _connect_all_signals() -> void:
	#Settings menu connections
	self.visibility_changed.connect(_on_settings_opened)
	_settings_tabs.tab_changed.connect(
		func(_tab: int): Audio.play_sfx(&"ui_select"))
	# HSlider connections
	for slider:HSlider in find_children(
			"*","HSlider",true) as Array[HSlider]:
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = _local_save.audio[slider.name]
		slider.value_changed.connect(
			func(_value: float): 
				_on_slider_value_changed(slider))
		_sliders.append(slider)
	# Button connections
	for button:Button in find_children(
			"*","Button",true) as Array[Button]:
		button.focus_mode = Control.FOCUS_NONE
		# OptionButton connections
		if button is OptionButton:
			var option: OptionButton = button as OptionButton
			option.item_selected.connect(
				func(_index: int): 
					_on_option_selected(option))
			_options.append(option)
		else:
			button.pressed.connect(
				_on_button_pressed.bind(button))

## Reverts all slider values to the local save state,
## which may differ from the global save file.
func _revert_settings() -> void:
	if not get_tree().current_scene is Title: return
	# Audio
	for slider:HSlider in _sliders:
		slider.value = _local_save.audio[slider.name]
		slider.emit_signal(&"value_changed",slider.value)
	# Display
	for option:OptionButton in _options:
		match(option.name):
			&"WindowMode":
				var index: int = option.get_item_index(
					_local_save.window_mode)
				option.select(index)
				option.emit_signal(&"item_selected",0)

## Creates a local save state of the global save data to
## alter the settings menu.
func _on_settings_opened() -> void:
	if not visible: return
	_local_save = Global.save.settings.duplicate()

## Saves or reverts the changes made in the save menu.
func _on_settings_closed(is_saved: bool) -> void:
	if is_saved:
		Global.save.settings = _local_save.duplicate()
	else:
		_local_save = Global.save.settings.duplicate()
	_revert_settings()

## The initializing function
func _ready() -> void:
	print("creating settings local_save...")
	_local_save = Global.save.settings.duplicate()
	_connect_all_signals()
	_revert_settings()
	
#endregion
#region ************* Public Methods ******************** #

#endregion
