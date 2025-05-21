class_name UserData extends Resource
## The base UserData class. [br]

#region *************** References ********************** #

#endregion
#region **************** Constants ********************** #

const LOGO_ICON_PATH: String = "res://assets/ui/icon.png"

const EXP_GROWTH_FACTOR: int = 5

#endregion
#region ************ Private Variables ****************** #

#endregion
#region ************ Public Variables ******************* #
## Immutable username.
@export_storage var name: String = \
	"Guest%s" % randi_range(111,999) 
@export_storage var color: Color = Color.WHITE
@export_storage var icon: Texture2D = \
	load(LOGO_ICON_PATH) as Texture2D

@export_storage var cosmetic: String = ""
@export_storage var level: int = 1
@export_storage var xp: int = 0
@export_storage var coins: int = 0

@export_storage var achievements: Dictionary[String,bool] = {
	"start_with_sanity":true,
	"it_begins":false, "we_shall_go_together":false,
	"together_once_more":false, "60_seconds":false,
	"light_it_up":false, "the_farlands":false,
	"lone_survivor":false, "bunker_trinity":false,
	"this_is_a_robbery":false, "delulu_is_not_the_solulu":false,
	"im_the_bad_guy":false, "the_imposter":false,
	"feel_the_heat":false, "last_prayers":false,
	"ao_oni":false, "hardships":false}

#endregion
#region ************* Private Methods ******************* #

#endregion
#region ************* Public Methods ******************** #

#endregion
