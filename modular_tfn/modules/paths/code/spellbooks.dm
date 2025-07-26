/obj/item/path_spellbook
	name = "Path Spellbook"
	desc = "A default path spellbook. if you're seeing this ingame, please report to coders"
	icon = 'modular_tfn/modules/paths/icons/paths.dmi' // TODO ICONS FOR ALL SPELLBOOKS AND THEIR OPENED STATES
	icon_state = "spellbook"
	var/path_type = null
	var/path_level = 1
	var/do_after_time = 300 // 30 seconds
// TODO : find the original creators of the sprites and acknowledge them in the PR - its held under creative commons 3.0

/obj/item/path_spellbook/attack_self(mob/living/carbon/human/user)

	// TODO : add a conditional where players cant just use the flames 5 spellbook and instantly learn all the previous dots

	if(!path_type)
		to_chat(user, span_warning("This spellbook appears to be incomplete!"))
		return

	if(istype(user.dna.species, /datum/species/kindred))
		if(!user.thaumaturgy_knowledge)
			to_chat(user, span_notice("You must have knowledge of Thaumaturgy to use this book!"))
			return
		else
			// TODO : use get_discipline() to check if the user already has this path, then check the level
			return
	else
		to_chat(user, span_warning("You must be a Kindred to use this spellbook!"))
		return

	var/original_icon_state = icon_state
	icon_state = "[original_icon_state]-opened"
	update_appearance()

	to_chat(user, span_notice("You begin studying the ancient texts..."))

	if(do_after(user, do_after_time, target = src))
		// TODO: the assigning of the appropriate path and its level deosnt appear to be working -- check adminverb 'Grant Discipline' for better handling, or perhaps discipline.assign also path.dm
		var/datum/discipline/discipline_instance = new path_type() //perhaps these need to be subtyped as the paths?
		discipline_instance.level_casting = path_level
		discipline_instance.assign(user)

		to_chat(user, span_notice("The knowledge of [name] flows into your mind!"))
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
