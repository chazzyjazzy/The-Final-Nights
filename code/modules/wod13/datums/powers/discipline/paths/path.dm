/datum/discipline/path
	check_flags = NONE
	button_icon = 'code/modules/wod13/UI/paths.dmi' //This is the file for the BACKGROUND icon
	background_icon_state = "default" //And this is the state for the background icon
	icon_icon = 'code/modules/wod13/UI/paths.dmi' //This is the file for the ACTION icon
	button_icon_state = "default" //And this is the state for the action icon

	vampiric = TRUE
	var/level_icon_state = "1" //And this is the state for the action icon
	var/datum/discipline/discipline
	var/targeting = FALSE

// this constructor is mainly for file seperation purposes so that we can keep all the path sprites in paths.dmi
