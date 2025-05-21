class_name Achievement extends Resource
## The base Achievement class. [br]

#region *************** References ********************** #

#endregion
#region **************** Constants ********************** #

#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #

var title: String ## The title of the achievement.
var desc: String ## A description on how to complete the achievement.

## The difficulty of the achievement as a color gradient
## from white to dark red (easy to challenging).
var color: Color = Color.WHITE

var unlocked: bool

#endregion
#region ************* Private Methods ******************* #

## Creates a new achievement.
@warning_ignore("shadowed_variable")
func _init(title: String, desc: String, 
		color: Color= Color.WHITE) -> void:
	self.title = title
	self.desc = desc
	self.color = color

#endregion
#region ************* Public Methods ******************** #

#endregion
