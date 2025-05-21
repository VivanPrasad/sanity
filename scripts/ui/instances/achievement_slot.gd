class_name AchievementSlot extends HBoxContainer
## The base AchievementSlot class. [br]

#region *************** References ********************** #

@onready var _icon_texture: TextureRect = $Icon as TextureRect
@onready var _locked_texture: TextureRect = \
	$Icon/MarginContainer/Locked as TextureRect
@onready var _title_label: Label = $VBoxContainer/Title as Label
@onready var _desc_label: Label = $VBoxContainer/Desc as Label

#endregion
#region **************** Constants ********************** #

const _LOCKED_ICON: Texture2D = preload("res://assets/ui/locked.png")
const _CHECK_ICON: Texture2D = preload("res://assets/ui/check.png")

#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #

#endregion
#region ************* Private Methods ******************* #

## Initializes the achievement slot labels and icons.
func _ready() -> void:
	var i: int = get_index()
	var achieve: Achievement = Global.AchievementList[i]
	_title_label.set_text(
		achieve.title.capitalize())
	_desc_label.set_text(achieve.desc)
	_icon_texture.set_modulate(achieve.color)
	
	
	if achieve.title in Global.save.user.achievements:
		achieve.unlocked = Global.save.user.achievements[achieve.title]
	
	if achieve.unlocked:
		_locked_texture.set_texture(_CHECK_ICON)
	else:
		_locked_texture.set_texture(_LOCKED_ICON)

#endregion
#region ************* Public Methods ******************** #

#endregion
