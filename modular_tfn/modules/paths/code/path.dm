/datum/discipline/path
	var/action_type = /datum/action/discipline/path
	var/action_replaced = FALSE // Track if we've already done the replacement


// ALERT : the discipline icons were interrupting with this alot, the parent type was overriding the subtype's icons, so below is a rather hammy method to replace it
// TODO : figure out the issue with these icons so that we don't have this monster of a solution to get correct icons from modular_tfn/whatever/paths.dmi instead of code/whateverwod13/actions.dmi
// TODO : The adminverb 'Remove Discipline' doesnt appear to properly remove the discipline. Removing a path then adding it again causes duplicates, and the previous one never goes away.

// Override post_gain to replace the action after the base system is done
/datum/discipline/path/post_gain()
	. = ..()

	// Only do this once per discipline
	if(action_replaced || !owner)
		return

	// Give the base system a moment to create the action, then replace it
	spawn(1)
		replace_base_action()

/datum/discipline/path/proc/replace_base_action()
	if(!owner)
		return

	// Find the base discipline action that was created for this discipline
	var/datum/action/discipline/base_action = null
	for(var/datum/action/discipline/action in owner.actions)
		if(action.discipline == src && action.type == /datum/action/discipline)
			base_action = action
			break

	if(base_action)
		// Create our path action
		var/datum/action/discipline/path/path_action = new /datum/action/discipline/path(src)

		// Grant the path action
		path_action.Grant(owner)

		// Remove the base action
		base_action.Remove(owner)
		qdel(base_action)

		action_replaced = TRUE

/datum/action/discipline/path
	check_flags = NONE
	button_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	background_icon_state = "default"
	icon_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	button_icon_state = "default"

/datum/action/discipline/path/New(datum/discipline/discipline)
	. = ..()

/datum/action/discipline/path/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	button_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	icon_icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	background_icon_state = "default"
	button_icon_state = "default"

	current_button.icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	current_button.icon_state = "default"

	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)

		if(discipline)
			current_button.name = discipline.current_power.name
			current_button.desc = discipline.current_power.desc

			// Add discipline icon overlay using path icons
			var/discipline_icon_state = discipline.icon_state || "default"
			current_button.add_overlay(mutable_appearance('modular_tfn/modules/paths/icons/paths.dmi', discipline_icon_state))
			current_button.button_icon_state = discipline_icon_state

			// Add level indicator overlay using path icons
			if(discipline.level_casting)
				current_button.add_overlay(mutable_appearance('modular_tfn/modules/paths/icons/paths.dmi', "[discipline.level_casting]"))
		else
			current_button.add_overlay(mutable_appearance('modular_tfn/modules/paths/icons/paths.dmi', "default"))
			current_button.button_icon_state = "default"
