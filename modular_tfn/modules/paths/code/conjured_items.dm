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

// Parent dropped behavior - handle being_deleted check and deletion
/obj/item/lighter/conjured/dropped(mob/user)
	. = ..()
	if(being_deleted)
		return
	being_deleted = TRUE
	qdel(src)

// Add a safe deletion proc for discipline deactivation
/obj/item/lighter/conjured/proc/discipline_delete()
	if(being_deleted)
		return
	being_deleted = TRUE
	qdel(src)

// Override parent behavior - can't be turned off
/obj/item/lighter/conjured/attack_self(mob/user)
	to_chat(user, span_notice("The supernatural flame cannot be extinguished by normal means."))
	return

// Override parent behavior - can't be placed on tables/surfaces normally
/obj/item/lighter/conjured/MouseDrop(atom/over_object, src_location, over_location)
	to_chat(usr, span_notice("The supernatural flame refuses to be placed down."))
	return TRUE // Return TRUE to prevent default behavior

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
	if(being_deleted)
		return
	being_deleted = TRUE

	if(prob(20))
		var/turf/target_turf = get_turf(src)
		if(target_turf)
			new /obj/effect/fire(target_turf)
	qdel(src)

/obj/item/lighter/conjured/flame/dropped(mob/user)
	. = ..() // Call parent which handles being_deleted check and qdel
	// Only create fire if this was a natural drop (not discipline deactivation)
	if(being_deleted && prob(20) && !QDELETED(src))
		var/turf/target_turf = get_turf(src)
		if(target_turf)
			new /obj/effect/fire(target_turf)

// Override discipline_delete to prevent fire creation during deactivation
/obj/item/lighter/conjured/flame/discipline_delete()
	if(being_deleted)
		return
	being_deleted = TRUE
	qdel(src) // Clean deletion without fire effects

/obj/item/lighter/conjured/flame/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		// Chance to ignite target
		if(prob(25))
			L.adjust_fire_stacks(1)
			L.IgniteMob()
		playsound(src, 'modular_tfn/modules/paths/sounds/fireball.ogg', 25, TRUE)

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
