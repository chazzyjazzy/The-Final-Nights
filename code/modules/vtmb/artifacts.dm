/obj/item/vtm_artifact/pickup(mob/user)
	..()
	if(identified)
		owner = user
		START_PROCESSING(SSobj, src)
		get_powers()

/obj/item/vtm_artifact/dropped(mob/user)
	..()
	if(identified)
		if(isturf(loc))
			STOP_PROCESSING(SSobj, src)
			if(owner)
				remove_powers()
				owner = null

/obj/item/vtm_artifact/process(delta_time)
	if(owner != loc && owner != loc.loc)
		forceMove(get_turf(src))
		STOP_PROCESSING(SSobj, src)
		if(owner)
			remove_powers()
			owner = null

/obj/item/vtm_artifact
	name = "unidentified occult fetish"
	desc = "Who knows what secrets it could contain..."
	icon_state = "arcane"
	icon = 'code/modules/wod13/items.dmi'
	onflooricon = 'code/modules/wod13/onfloor.dmi'
	w_class = WEIGHT_CLASS_SMALL
	is_magic = TRUE
	var/mob/living/owner
	var/true_name = "artifact"
	var/true_desc = "Debug"
	var/identified = FALSE
	var/gained_boosts = FALSE

/obj/item/vtm_artifact/proc/identificate()
	if(!identified)
		name = true_name
		desc = true_desc
		identified = TRUE

/obj/item/vtm_artifact/proc/get_powers()
	if(!identified)
		return

/obj/item/vtm_artifact/proc/remove_powers()
	if(!identified)
		return


// ---------------------------------------------WEEKAPAUG THISTLE-----------------------------------------------------------
/obj/item/vtm_artifact/weekapaug_thistle
	true_name = "Weekapaug Thistle"
	true_desc = "Increases combat defense."
	icon_state = "w_thistle"

/obj/item/vtm_artifact/weekapaug_thistle/get_powers()
	..()
	var/mob/living/carbon/human/H = owner
	H.physiology.armor.melee = H.physiology.armor.melee+10
	H.physiology.armor.bullet = H.physiology.armor.bullet+10

/obj/item/vtm_artifact/weekapaug_thistle/remove_powers()
	..()
	var/mob/living/carbon/human/H = owner
	H.physiology.armor.melee = H.physiology.armor.melee-10
	H.physiology.armor.bullet = H.physiology.armor.bullet-10

/*
/obj/item/vtm_artifact/tarulfang
	true_name = "Tarulfang"
	true_desc = "Decreases chance of frenzy."
	icon_state = "tarulfang"
*/
/obj/item/vtm_artifact/weekapaug_thistle/get_powers()
	..()
	owner.frenzy_chance_boost = 5

/obj/item/vtm_artifact/weekapaug_thistle/remove_powers()
	..()
	owner.frenzy_chance_boost = 10

// ---------------------------------------------MUMMYWRAP FETISH-----------------------------------------------------------
/obj/item/vtm_artifact/mummywrap_fetish
	true_name = "Mummywrap Fetish"
	true_desc = "Passive health regeneration."
	icon_state = "m_fetish"
	var/last_regen = 0

/obj/item/vtm_artifact/mummywrap_fetish/process(delta_time)
	. = ..()
	if(identified && owner)
		if(last_regen+60 < world.time)
			last_regen = world.time
			owner.adjustBruteLoss(-5)
			owner.adjustFireLoss(-5)

/*
/obj/item/vtm_artifact/saulocept
	true_name = "Saulocept"
	true_desc = "More experience points."
	icon_state = "saulocept"

/obj/item/vtm_artifact/saulocept/get_powers()
	..()
	owner.experience_plus = 10

/obj/item/vtm_artifact/saulocept/remove_powers()
	..()
	owner.experience_plus = 0
*/

// ---------------------------------------------GALDJUM-----------------------------------------------------------
/obj/item/vtm_artifact/galdjum
	true_name = "Galdjum"
	true_desc = "Increases disciplines duration."
	icon_state = "galdjum"

/obj/item/vtm_artifact/galdjum/get_powers()
	..()
	owner.discipline_time_plus = 25

/obj/item/vtm_artifact/galdjum/remove_powers()
	..()
	owner.discipline_time_plus = 0


// ---------------------------------------------FAE CHARM-----------------------------------------------------------
/datum/movespeed_modifier/fae_charm
	multiplicative_slowdown = -0.20

/obj/item/vtm_artifact/fae_charm
	true_name = "Fae Charm"
	true_desc = "Faster movement speed."
	icon_state = "fae_charm"

/obj/item/vtm_artifact/fae_charm/get_powers()
	..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/fae_charm)

/obj/item/vtm_artifact/fae_charm/remove_powers()
	..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/fae_charm)


// ---------------------------------------------HEART OF ELIZA-----------------------------------------------------------
/obj/item/vtm_artifact/heart_of_eliza
	true_name = "Heart of Eliza"
	true_desc = "Melee damage boost."
	icon_state = "h_eliza"

/obj/item/vtm_artifact/heart_of_eliza/get_powers()
	..()
	var/mob/living/carbon/human/H = owner
	if(H.dna)
		H.dna.species.meleemod = H.dna.species.meleemod+0.5

/obj/item/vtm_artifact/heart_of_eliza/remove_powers()
	..()
	var/mob/living/carbon/human/H = owner
	if(H.dna)
		H.dna.species.meleemod = H.dna.species.meleemod-0.5


//// ---------------------------------------------BLOODSTAR-----------------------------------------------------------
/obj/item/vtm_artifact/bloodstar
	true_name = "Bloodstar"
	true_desc = "Increases Bloodpower duration."
	icon_state = "bloodstar"

/obj/item/vtm_artifact/bloodstar/get_powers()
	..()
	owner.bloodpower_time_plus = 50

/obj/item/vtm_artifact/bloodstar/remove_powers()
	..()
	owner.bloodpower_time_plus = 0


// ---------------------------------------------DAIMONORI-----------------------------------------------------------
/obj/item/vtm_artifact/daimonori
	true_name = "Daimonori"
	true_desc = "Increases thaumaturgy damage."
	icon_state = "daimonori"

/obj/item/vtm_artifact/daimonori/get_powers()
	..()
	owner.thaum_damage_plus = 10

/obj/item/vtm_artifact/daimonori/remove_powers()
	..()
	owner.thaum_damage_plus = 0


// ---------------------------------------------KEY OF ALAMUT-----------------------------------------------------------
/obj/item/vtm_artifact/key_of_alamut
	true_name = "Key of Alamut"
	true_desc = "Decreases incoming damage."
	icon_state = "k_alamut"

/obj/item/vtm_artifact/key_of_alamut/get_powers()
	..()
	var/mob/living/carbon/human/H = owner
	if(H.dna.species.brutemod == 0.3)
		return
	if(H.dna)
		H.dna.species.brutemod = H.dna.species.brutemod-0.2
		H.dna.species.burnmod = H.dna.species.burnmod-0.2

/obj/item/vtm_artifact/key_of_alamut/remove_powers()
	..()
	var/mob/living/carbon/human/H = owner
	if(H.dna.species.brutemod == 0.5)
		return
	if(H.dna)
		H.dna.species.brutemod = H.dna.species.brutemod+0.2
		H.dna.species.burnmod = H.dna.species.burnmod+0.2

// ---------------------------------------------ODIOUS CHALICE-----------------------------------------------------------
/obj/item/vtm_artifact/odious_chalice
	true_name = "Odious Chalice"
	true_desc = "Stores blood from every attack."
	icon_state = "o_chalice"
	var/stored_blood = 0

/obj/item/vtm_artifact/odious_chalice/examine(mob/user)
	. = ..()
	. += "[src] contains [stored_blood] blood points..."

/obj/item/vtm_artifact/odious_chalice/attack(mob/living/M, mob/living/user)
	. = ..()
	if(!iskindred(M))
		return
	if(!stored_blood)
		return
	if(!identified)
		return
	M.adjustBruteLoss(-5*stored_blood, TRUE)
	M.adjustFireLoss(-5*stored_blood, TRUE)
	M.update_damage_overlays()
	M.update_health_hud()
	M.update_blood_hud()
	playsound(M.loc,'sound/items/drink.ogg', 50, TRUE)
	return

// ---------------------------------------------BLOODSTONE-----------------------------------------------------------
/datum/action/bloodstone_track
	name = "Track Bloodstone"
	desc = "Sense the location of your bound bloodstone."
	button_icon = 'modular_tfn/modules/paths/icons/bloodstone_artifact.dmi'
	button_icon_state = "bloodstone_track"
	check_flags = AB_CHECK_CONSCIOUS
	var/obj/item/vtm_artifact/bloodstone/tracked_stone

/datum/action/bloodstone_track/New(Target, obj/item/vtm_artifact/bloodstone/stone)
	..()
	tracked_stone = stone

/datum/action/bloodstone_track/Trigger(trigger_flags)
	if(!tracked_stone)
		to_chat(owner, span_warning("The bloodstone bond has been severed."))
		Remove(owner)
		return FALSE

	var/turf/stone_turf = get_turf(tracked_stone)
	if(!stone_turf)
		to_chat(owner, span_warning("You cannot sense the bloodstone's location."))
		return FALSE

	var/area/stone_area = get_area(tracked_stone)
	to_chat(owner, span_notice("The bloodstone whispers its location: [stone_area.name] ([stone_turf.x], [stone_turf.y])"))
	return TRUE

/datum/action/bloodstone_track/IsAvailable(feedback = FALSE)
	if(!tracked_stone)
		return FALSE
	return ..()

/obj/item/vtm_artifact/bloodstone
	true_name = "Bloodstone"
	true_desc = "A pulsing crimson stone that creates a mystical bond with its identifier."
	icon = 'modular_tfn/modules/paths/icons/bloodstone_artifact.dmi'
	onflooricon = 'modular_tfn/modules/paths/icons/bloodstone_artifact.dmi'
	icon_state = "bloodstone"
	var/mob/living/carbon/human/bound_identifier // Who identified it first
	var/datum/action/bloodstone_track/tracking_action


/obj/item/vtm_artifact/bloodstone/identificate()
	..()
	if(identified && !bound_identifier)
		var/mob/living/carbon/human/user = usr
		if(ishuman(user))
			bound_identifier = user
			to_chat(user, span_warning("The bloodstone pulses with dark energy as it bonds to your essence. You will always know its location."))

			// Grant the tracking action
			tracking_action = new /datum/action/bloodstone_track(user, src)
			tracking_action.Grant(user)

/obj/item/vtm_artifact/bloodstone/Destroy()
	// Clean up the action when bloodstone is destroyed
	if(tracking_action)
		tracking_action.Remove(bound_identifier)
		QDEL_NULL(tracking_action)
	return ..()


/obj/item/vtm_artifact/rand
	icon_state = "art_rand"

/obj/item/vtm_artifact/rand/Initialize()
	. = ..()
	if (prob(50)) //50% chance of spawning something
		var/spawn_artifact = pick(/obj/item/vtm_artifact/odious_chalice, /obj/item/vtm_artifact/key_of_alamut,
									/obj/item/vtm_artifact/daimonori, /obj/item/vtm_artifact/bloodstar,
									/obj/item/vtm_artifact/heart_of_eliza, /obj/item/vtm_artifact/fae_charm,
									/obj/item/vtm_artifact/galdjum, /obj/item/vtm_artifact/mummywrap_fetish,
									/obj/item/vtm_artifact/weekapaug_thistle, /obj/item/vtm_artifact/bloodstone)
		new spawn_artifact(loc)
	qdel(src)
