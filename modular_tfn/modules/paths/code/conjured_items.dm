// Base conjured lighter class with shared characteristics
/obj/item/lighter/conjured
	// Shared variables
	var/being_deleted = FALSE // Prevent double deletion

	// Shared characteristics for all conjured lighters
	lit = TRUE
	light_system = MOVABLE_LIGHT
	light_on = TRUE
	damtype = BURN

	// Common icon paths (can be overridden)
	icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	lefthand_file = 'modular_tfn/modules/paths/icons/paths_inhand_lefthand.dmi'
	righthand_file = 'modular_tfn/modules/paths/icons/paths_inhand_righthand.dmi'

// Add a safe deletion proc for discipline deactivation
/obj/item/lighter/conjured/proc/discipline_delete()
	if(being_deleted || QDELETED(src))
		return
	qdel(src)

// Override parent behavior - can't be turned off
/obj/item/lighter/conjured/attack_self(mob/user)
	to_chat(user, span_notice("The supernatural flame cannot be extinguished by normal means."))
	return

// Keep the flame always lit
/obj/item/lighter/conjured/set_lit(new_lit)
	if(!new_lit)
		return // Cannot be extinguished
	return ..() // Allow lighting if somehow unlit

/obj/item/lighter/conjured/Initialize(mapload)
	. = ..()
	set_light_on(TRUE)

// Flame-based conjured items (candle and palm of flame)
/obj/item/lighter/conjured/flame
	// Shared flame characteristics
	light_range = 3
	light_power = 1
	light_color = COLOR_ORANGE

/obj/item/lighter/conjured/flame/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(being_deleted || QDELETED(src))
		return

	// Create fire effect before deletion
	if(prob(20))
		var/turf/target_turf = get_turf(src)
		if(target_turf)
			new /obj/effect/fire(target_turf)

	qdel(src)

/obj/item/lighter/conjured/flame/dropped(mob/user)
	if(being_deleted || QDELETED(src))
		return

	// Create fire effect before deletion (only on natural drops)
	if(prob(20))
		var/turf/target_turf = get_turf(src)
		if(target_turf)
			new /obj/effect/fire(target_turf)

	. = ..() // Call parent which will qdel

// Specific flame implementations
/obj/item/lighter/conjured/flame/candle
	name = "Lure of Flames - Candle"
	desc = "From your finger sprouts out the small flame of a candle."
	icon_state = "candle"
	inhand_icon_state = "candle"
	force = 10

/obj/item/lighter/conjured/flame/palm_of_flame
	name = "hand of flame"
	desc = "Your hand burns with supernatural fire."
	icon_state = "flame"
	inhand_icon_state = "flame"
	force = 20
	fancy = FALSE // Disable fancy lighter messages

// Electric-based conjured item (levinbolt)
/obj/item/lighter/conjured/levinbolt_arm
	name = "Illuminate"
	desc = "Your arm surges with electricity!"
	icon_state = "illuminate"
	inhand_icon_state = "illuminate"
	force = 20
	light_range = 2
	light_power = 1
	light_color = COLOR_WHITE
