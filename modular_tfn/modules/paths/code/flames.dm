/datum/discipline/path/flames
	name = "Lure of Flames"
	desc = "A mystical path of Thaumaturgy that allows the summoning of fire and flame. Violates Masquerade."
	icon_state = "flames"
	power_type = /datum/discipline_power/thaumaturgy/path/flames

/datum/discipline_power/thaumaturgy/path/flames
	name = "Lure of Flames Power Name"
	desc = "Lure of Flames Power Description"

	effect_sound = 'modular_tfn/modules/paths/sounds/fireball.ogg'



// hand of flame
// flame bolt
// pillar of fire
// engulf
// firestorm

// pretty certain these are not lore accurate particularly flame bolt

// Hand of Flame lighter item
/obj/item/lighter/hand_of_flame
	name = "hand of flame"
	desc = "Your hand burns with supernatural fire."
	icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	icon_state = "flame" // TODO SPRITES
	inhand_icon_state = "flame" // TODO SPRITES
	lefthand_file = 'modular_tfn/modules/paths/icons/paths_inhand_lefthand.dmi'
	righthand_file = 'modular_tfn/modules/paths/icons/paths_inhand_righthand.dmi'
	force = 20
	damtype = BURN
	lit = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_color = COLOR_ORANGE
	light_on = TRUE

/obj/item/lighter/hand_of_flame/Initialize(mapload)
	. = ..()
	set_light_on(TRUE)

/obj/item/lighter/hand_of_flame/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		// Chance to ignite target
		if(prob(25)) // TODO make this a thaumaturgy / mentality roll, unless base probs are ok
			L.adjust_fire_stacks(1)
			L.IgniteMob()
		playsound(src, 'modular_tfn/modules/paths/sounds/fireball.ogg', 25, TRUE)

//HAND OF FLAME - Level 1
/datum/discipline_power/thaumaturgy/path/flames/one
	name = "Hand of Flame"
	desc = "Ignite your hands with supernatural fire, adding burn damage to your punches."

	level = 1

	check_flags = DISC_CHECK_CAPABLE
	violates_masquerade = TRUE

	toggled = TRUE
	duration_length = 6 TURNS // how long is a turn again? 5 seconds maybe?

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/two,
		/datum/discipline_power/thaumaturgy/path/flames/three,
		/datum/discipline_power/thaumaturgy/path/flames/four,
		/datum/discipline_power/thaumaturgy/path/flames/five
	)

/datum/discipline_power/thaumaturgy/path/flames/one/activate()
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/lighter/hand_of_flame(owner))
	owner.put_in_l_hand(new /obj/item/lighter/hand_of_flame(owner))

/datum/discipline_power/thaumaturgy/path/flames/one/deactivate()
	. = ..()
	// Remove flame weapons
	for(var/obj/item/lighter/hand_of_flame/flame in owner.held_items)
		qdel(flame)

//FLAME BOLT - Level 2
// TODO : ok now this is just a 'fireball' spell - not sure if thats canon/wanted, perhaps we make it like one, but add the ability for the user to 'throw' the fire.
/datum/discipline_power/thaumaturgy/path/flames/two
	name = "Flame Bolt"
	desc = "Hurl a bolt of supernatural fire at your target."

	level = 2
	cooldown_length = 1 SECONDS
	violates_masquerade = TRUE
	range = 7
	target_type = TARGET_LIVING

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/one,
		/datum/discipline_power/thaumaturgy/path/flames/three,
		/datum/discipline_power/thaumaturgy/path/flames/four,
		/datum/discipline_power/thaumaturgy/path/flames/five
	)

// TODO : add a botch where the user gets set on fire instead. these abilities should be strong - as they're acquired mid-round through 'jobby' activities, but they need 'magical accident' drawbacks
/datum/discipline_power/thaumaturgy/path/flames/two/activate(mob/living/target)
	. = ..()
	var/turf/start = get_turf(owner)
	var/obj/projectile/flames/flamebolt/H = new(start)
	H.firer = owner
	H.damage = 20 + owner.thaum_damage_plus + owner.get_total_mentality()
	H.preparePixelProjectile(target, start)
	H.level = 2
	H.fire(direct_target = target)
	H.cruelty_multiplier = 1.1
	to_chat(target, span_danger("A bolt of searing flame flies toward you!"))


//PILLAR OF FIRE - Level 3
/datum/discipline_power/thaumaturgy/path/flames/three
	name = "Pillar of Fire"
	desc = "Summon a towering pillar of flame from the ground beneath your target."

	level = 3
	cooldown_length = 10 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 7

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/one,
		/datum/discipline_power/thaumaturgy/path/flames/two,
		/datum/discipline_power/thaumaturgy/path/flames/four,
		/datum/discipline_power/thaumaturgy/path/flames/five
	)

// TODO : Right now this ability is a placeholder, just does damage and adds a fire stack, very boring
/datum/discipline_power/thaumaturgy/path/flames/three/activate(mob/living/target)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	// Deal damage
	var/damage_amount = 25 + owner.thaum_damage_plus + owner.get_total_mentality()
	target.adjustFireLoss(damage_amount)

	// Chance to ignite
	if(prob(60))
		target.adjust_fire_stacks(3)
		target.IgniteMob()

	to_chat(target, span_userdanger("A massive pillar of fire erupts beneath you!"))
	playsound(target_turf, effect_sound, 50, TRUE)

//ENGULF - Level 4
/datum/discipline_power/thaumaturgy/path/flames/four
	name = "Engulf"
	desc = "Surround your target in a raging inferno, dealing continuous burn damage."

	level = 4
	cooldown_length = 10 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 7

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/one,
		/datum/discipline_power/thaumaturgy/path/flames/two,
		/datum/discipline_power/thaumaturgy/path/flames/three,
		/datum/discipline_power/thaumaturgy/path/flames/five
	)

// TODO : Right now this ability is a placeholder just like three, just does damage and adds a flamestack, very boring, it can be better
/datum/discipline_power/thaumaturgy/path/flames/four/activate(mob/living/target)
	. = ..()
	if(!target)
		return

	// Initial damage
	var/damage_amount = 30 + owner.thaum_damage_plus + owner.get_total_mentality()
	target.adjustFireLoss(damage_amount)

	// Heavy fire stacks and ignition
	target.adjust_fire_stacks(8)
	target.IgniteMob()

	to_chat(target, span_userdanger("You are engulfed in supernatural flames!"))
	playsound(get_turf(target), effect_sound, 75, TRUE)

//INFERNO - Level 5
/datum/discipline_power/thaumaturgy/path/flames/five
	name = "Inferno"
	desc = "Unleash a devastating storm of fire that affects multiple targets in an area."

	level = 5
	cooldown_length = 20 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_TURF | TARGET_LIVING
	range = 10

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/one,
		/datum/discipline_power/thaumaturgy/path/flames/two,
		/datum/discipline_power/thaumaturgy/path/flames/three,
		/datum/discipline_power/thaumaturgy/path/flames/four
	)

/datum/discipline_power/thaumaturgy/path/flames/five/activate(atom/target)
	. = ..()

	// Return early if the base thaumaturgy activation failed or botched
	if(.)
		return

	to_chat(owner, span_notice("You begin channeling a devastating firestorm..."))

	// Get the target turf
	var/turf/center = get_turf(target)

	// Calculate area size based on successes (minimum 1 tile, maximum 2 tiles from center)
	var/area_range = clamp(success_count, 1, 2)

	// Create warning overlays first
	var/list/affected_turfs = list()
	for(var/turf/T in range(area_range, center))
		affected_turfs += T
		// Add warning overlay from fire.dmi
		new /obj/effect/temp_visual/inferno_warning(T)
	// Show warning message
	owner.visible_message(span_warning("[owner] begins channeling dangerous magic, reality warping around the target area!"))

	// Wait for channel time - this gives players time to see the warning and react
	if(!do_after(owner, 4 SECONDS))
		to_chat(owner, span_warning("Your firestorm casting was interrupted!"))
		// Clean up any remaining warning overlays
		for(var/turf/T in affected_turfs)
			for(var/obj/effect/temp_visual/inferno_warning/W in T)
				qdel(W)
		return

	// Calculate damage and fire stacks based on successes
	var/base_damage = 20 + (success_count * 5) + owner.thaum_damage_plus + owner.get_total_mentality()
	var/fire_stacks_amount = 3 + success_count
	var/ignite_chance = min(60 + (success_count * 10), 95) // 60% base, +10% per success, max 95%

	// Create the actual inferno effect
	for(var/turf/T in affected_turfs)
		// Remove warning overlay and create fire effect
		for(var/obj/effect/temp_visual/inferno_warning/W in T)
			qdel(W)
		new /obj/effect/fire(T)

		// Damage all mobs on each tile
		for(var/mob/living/L in T)
			if(L == owner) // Don't damage self - but caster still gets set on fire
				continue

			L.adjustFireLoss(base_damage)

			// Chance to ignite based on successes
			if(prob(ignite_chance))
				L.adjust_fire_stacks(fire_stacks_amount)
				L.IgniteMob()

			to_chat(L, span_userdanger("You are caught in a supernatural firestorm!"))

	playsound(center, effect_sound, 100, TRUE)
	owner.visible_message(span_danger("[owner] unleashes a devastating firestorm!"))

	// Show success-based feedback to caster
	switch(success_count)
		if(1)
			to_chat(owner, span_notice("Your firestorm burns with modest intensity."))
		if(2)
			to_chat(owner, span_notice("Your firestorm rages with considerable power."))
		if(3 to INFINITY)
			to_chat(owner, span_notice("Your firestorm burns with devastating supernatural fury!"))

// Warning overlay object
/obj/effect/temp_visual/inferno_warning
	name = "impending inferno"
	desc = "The air shimmers with dangerous heat. Something terrible is about to happen here!"
	icon = 'icons/effects/fire.dmi'
	icon_state = "fire"
	alpha = 150
	duration = 4 SECONDS // Matches the channel time

/obj/effect/temp_visual/inferno_warning/Initialize()
	. = ..()
	// Add a pulsing animation to make it more noticeable
	animate(src, alpha = 50, time = 10, loop = -1)
	animate(alpha = 200, time = 10)

	// Optional: Add a warning message to anyone who enters the tile
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, .proc/warn_entering_mob)

/obj/effect/temp_visual/inferno_warning/proc/warn_entering_mob(datum/source, atom/movable/entered)
	if(isliving(entered))
		var/mob/living/L = entered
		to_chat(L, span_warning("You feel intense supernatural heat building in this area!"))

// Projectile for Flame Bolt - based on thaumaturgy projectile
/obj/projectile/flames
	name = "flame"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "fireball"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = LASER
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_ORANGE
	ricochets_max = 0
	ricochet_chance = 0
	var/level = 1

/obj/projectile/flames/flamebolt
	name = "flame bolt"
	damage = 20

/obj/projectile/flames/flamebolt/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		// Chance to ignite target
		if(prob(10))
			L.adjust_fire_stacks(2)
			L.IgniteMob()
		L.visible_message(span_danger("[target] is struck by supernatural flames!"), span_userdanger("You are burned by supernatural fire!"))
		playsound(get_turf(target), 'modular_tfn/modules/paths/sounds/fireball.ogg', 50, TRUE)
