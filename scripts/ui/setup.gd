extends Control
## Description: 

#region *************** References ********************** #
@onready var username: LineEdit = $MarginContainer/VBoxContainer/Username

#endregion
#region **************** Constants ********************** #

#endregion
#region **************** Variables ********************** #

#endregion
#region ***************** Methods *********************** #

func _on_text_changed(line: LineEdit) -> void:
	match(line.name):
		
		_: print("")
func _connect_all_signals() -> void:
	for line: LineEdit in find_children(
			"*","LineEdit",true) as Array[LineEdit]:
		line.text_changed.connect(
			func(_text: String): _on_text_changed(line))
func _ready() -> void:
	_connect_all_signals()

#endregion
