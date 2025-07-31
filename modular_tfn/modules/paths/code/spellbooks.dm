/obj/item/path_spellbook
	name = "Path Spellbook"
	desc = "A default path spellbook. if you're seeing this ingame, please report to coders"
	icon = 'modular_tfn/modules/paths/icons/paths.dmi' // TODO ICONS FOR ALL SPELLBOOKS AND THEIR OPENED STATES
	icon_state = "spellbook"
	var/path_type = null
	var/path_level = 1
	var/do_after_time = 300 // 30 seconds
	var/activate_sound = 'modular_tfn/modules/paths/sounds/open_book.wav' // sound played when the spellbook is used
	var/deactivate_sound = 'modular_tfn/modules/paths/sounds/close_book.wav' // sound played when the spellbook is finished using
// TODO : find the original creators of the sprites and acknowledge them in the PR - its held under creative commons 3.0

/obj/item/path_spellbook/attack_self(mob/living/carbon/human/user)
	var/is_knowing = FALSE

	if(!path_type)
		to_chat(user, span_warning("This spellbook appears to be incomplete!"))
		return

	if(istype(user.dna.species, /datum/species/kindred))
		if(!user.thaumaturgy_knowledge)
			to_chat(user, span_warning("You must have knowledge of Thaumaturgy to use this book!"))
			return
		else
			for(var/datum/action/discipline/D in user.actions)
				if(D)
					if(D.discipline)
						//Checking if the discipline is the same as the path_type
						if(D.discipline.type == path_type)
							is_knowing = TRUE
							//Then we check if the level can be learned
							if(path_level == D.discipline.level)
								// User already knows this level
								to_chat(user, span_warning("You already know this book!"))
								return
							else if(path_level == D.discipline.level + 1)
								// The book's level is one higher than the user's current level
								to_chat(user, span_notice("Debug - You can learn this book!"))
								user.playsound_local(user, activate_sound, 50, FALSE)
							else if (path_level > D.discipline.level + 1)
								// The book's level is too high for the user to learn
								to_chat(user, span_warning("You must learn the previous book(s) first!"))
								return
							else if (path_level < D.discipline.level)
								// The book's level is lower than the user's current level
								to_chat(user, span_warning("You already know a higher level of this path!"))
								return
			// If we reach here, the user does not know this path at all
			if(path_level > 1 && !is_knowing)
				to_chat(user, span_warning("You must know the first level of this path before you can learn higher levels!"))
				return
			else if(path_level == 1 && !is_knowing)
				to_chat(user, span_notice("Debug - You do not know the path and can learn it!"))
				user.playsound_local(user, activate_sound, 50, FALSE)
	else
		to_chat(user, span_warning("You must be a Kindred to use this spellbook!"))
		return

	var/original_icon_state = icon_state
	icon_state = "[original_icon_state]-opened"
	update_appearance()

	to_chat(user, span_notice("You begin studying the ancient texts..."))

	if(do_after(user, do_after_time, target = src))
		// Now checking the level again to assign the correct path level
		if(!is_knowing)
			var/datum/discipline/new_discipline = new path_type(path_level)
			var/datum/species/kindred/species = user.dna.species
			species.disciplines += new_discipline
			var/datum/action/discipline/path/path_action = new /datum/action/discipline/path(new_discipline)
			path_action.Grant(user)

			to_chat(user, span_notice("The knowledge of [name] flows into your mind!"))
		else
			// If the user already knows the path, update the level
			// TODO: Updating the level of the path causes it to become unusable, despite learning it being just fine
			for(var/datum/action/discipline/D in user.actions)
				if(D && D.discipline && D.discipline.type == path_type)
					D.discipline.set_level(path_level)
					to_chat(user, span_notice("You have increased your knowledge of [name]!"))
					break

		user.playsound_local(user, deactivate_sound, 50, FALSE)
		qdel(src)
	else
		icon_state = original_icon_state
		update_appearance()
		to_chat(user, span_warning("Your concentration was broken!"))

// Lure of Flames Spellbooks
/obj/item/path_spellbook/lure_of_flames
	name = "Lure of Flames Spellbook"
	desc = "A tome containing the secrets of manipulating fire through blood magic."
	icon_state = "flames_spellbook"
	path_type = /datum/discipline/path/flames

/obj/item/path_spellbook/lure_of_flames/level1
	name = "Lure of Flames Spellbook (Level I)"
	desc = "A basic tome teaching the fundamentals of fire manipulation."
	path_level = 1

/obj/item/path_spellbook/lure_of_flames/level2
	name = "Lure of Flames Spellbook (Level II)"
	desc = "An intermediate tome revealing deeper secrets of flame control."
	path_level = 2

/obj/item/path_spellbook/lure_of_flames/level3
	name = "Lure of Flames Spellbook (Level III)"
	desc = "An advanced tome containing dangerous fire magic techniques."
	path_level = 3

/obj/item/path_spellbook/lure_of_flames/level4
	name = "Lure of Flames Spellbook (Level IV)"
	desc = "A master-level tome with devastating flame powers."
	path_level = 4

/obj/item/path_spellbook/lure_of_flames/level5
	name = "Lure of Flames Spellbook (Level V)"
	desc = "The ultimate tome of fire mastery, containing the most powerful flame techniques."
	path_level = 5

// Levinbolt Spellbooks
/obj/item/path_spellbook/levinbolt
	name = "Levinbolt Spellbook"
	desc = "A tome containing the secrets of channeling lightning through blood magic."
	icon_state = "levinbolt_spellbook"
	path_type = /datum/discipline/path/levinbolt

/obj/item/path_spellbook/levinbolt/level1
	name = "Levinbolt Spellbook (Level I)"
	desc = "A basic tome teaching the fundamentals of lightning manipulation."
	path_level = 1

/obj/item/path_spellbook/levinbolt/level2
	name = "Levinbolt Spellbook (Level II)"
	desc = "An intermediate tome revealing deeper secrets of electrical control."
	path_level = 2

/obj/item/path_spellbook/levinbolt/level3
	name = "Levinbolt Spellbook (Level III)"
	desc = "An advanced tome containing dangerous lightning magic techniques."
	path_level = 3

/obj/item/path_spellbook/levinbolt/level4
	name = "Levinbolt Spellbook (Level IV)"
	desc = "A master-level tome with devastating electrical powers."
	path_level = 4

/obj/item/path_spellbook/levinbolt/level5
	name = "Levinbolt Spellbook (Level V)"
	desc = "The ultimate tome of lightning mastery, containing the most powerful electrical techniques."
	path_level = 5
