/datum/discipline/path
	var/action_type = /datum/action/discipline/path

/datum/action/discipline/path
	check_flags = NONE
	button_icon = 'modular_tfn/modules/paths/icons/paths.dmi' //Paths use paths.dmi instead of actions.dmi
	background_icon_state = "default" //Paths use 'default' background
	icon_icon = 'modular_tfn/modules/paths/icons/paths.dmi' //Action icon also from paths.dmi
	button_icon_state = "default" //Default button state for paths

/datum/action/discipline/path/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	// Check if this is a path discipline and use different icons
	if(istype(discipline, /datum/discipline/path))
		button_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
		icon_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
		background_icon_state = "default"
	else
		button_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
		icon_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
		background_icon_state = "discipline"

	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)
		if(discipline)
			current_button.name = discipline.current_power.name
			current_button.desc = discipline.current_power.desc
			current_button.add_overlay(mutable_appearance(icon_icon, "[discipline.icon_state]"))
			current_button.button_icon_state = "[discipline.icon_state]"
			current_button.add_overlay(mutable_appearance(icon_icon, "[discipline.level_casting]"))
		else
			current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
			current_button.button_icon_state = button_icon_state
