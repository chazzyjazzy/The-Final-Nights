/datum/discipline/path
	// Paths use the standard discipline structure but different icon handling

/datum/action/discipline/path
	check_flags = NONE
	button_icon = 'code/modules/wod13/UI/paths.dmi' //Paths use paths.dmi instead of actions.dmi
	background_icon_state = "default" //Paths use 'default' background
	icon_icon = 'code/modules/wod13/UI/paths.dmi' //Action icon also from paths.dmi
	button_icon_state = "default" //Default button state for paths

// Path discipline powers use the standard discipline_power structure
/datum/discipline_power/path
	name = "Path power name"
	desc = "Path power description"
