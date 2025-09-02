/datum/discipline/path/flames
	name = "Lure of Flames"
	desc = "A mystical path of Thaumaturgy that allows the summoning of fire and flame. Violates Masquerade."
	icon_state = "flames"
	power_type = /datum/discipline_power/thaumaturgy/path/flames

/datum/discipline_power/thaumaturgy/path/flames
	name = "Lure of Flames Power Name"
	desc = "Lure of Flames Power Description"

	effect_sound = 'modular_tfn/modules/paths/sounds/fireball.ogg'



// candle
// palm of flame
// campfire
// engulf
// firestorm

// pretty certain these are not lore accurate particularly flame bolt


//Candle
/datum/discipline_power/thaumaturgy/path/flames/one
	name = "Candle"
	desc = "Conjure a flame that is the size of a candle. Can be used as a lighter - not much else."

	level = 1
	violates_masquerade = TRUE
	toggled = TRUE

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/two,
		/datum/discipline_power/thaumaturgy/path/flames/three,
		/datum/discipline_power/thaumaturgy/path/flames/four,
		/datum/discipline_power/thaumaturgy/path/flames/five
	)

/datum/discipline_power/thaumaturgy/path/flames/one/activate()
	. = ..()
	owner.drop_all_held_items()
	var/obj/item/lighter/conjured/flame/candle/right_candle = new(owner)
	var/obj/item/lighter/conjured/flame/candle/left_candle = new(owner)
	// Mark them as discipline items so deactivate can find them
	right_candle.being_deleted = FALSE
	left_candle.being_deleted = FALSE
	owner.put_in_r_hand(right_candle)
	owner.put_in_l_hand(left_candle)

/datum/discipline_power/thaumaturgy/path/flames/one/deactivate()
	. = ..()
	// Remove flame weapons safely without dropping them
	for(var/obj/item/lighter/conjured/flame/candle/candle in owner.held_items)
		candle.discipline_delete()

//PALM OF FLAME - Level 2
/datum/discipline_power/thaumaturgy/path/flames/two
	name = "Palm of Flame"
	desc = "Ignite your hands with supernatural fire, adding burn damage to your punches."

	level = 2

	check_flags = DISC_CHECK_CAPABLE
	violates_masquerade = TRUE

	toggled = TRUE
	duration_length = 2 TURNS // how long is a turn again? 5 seconds maybe?

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/flames/one,
		/datum/discipline_power/thaumaturgy/path/flames/three,
		/datum/discipline_power/thaumaturgy/path/flames/four,
		/datum/discipline_power/thaumaturgy/path/flames/five
	)

/datum/discipline_power/thaumaturgy/path/flames/two/activate()
	. = ..()
	owner.drop_all_held_items()
	var/obj/item/lighter/conjured/flame/palm_of_flame/right_flame = new(owner)
	var/obj/item/lighter/conjured/flame/palm_of_flame/left_flame = new(owner)
	// Mark them as discipline items so deactivate can find them
	right_flame.being_deleted = FALSE
	left_flame.being_deleted = FALSE
	owner.put_in_r_hand(right_flame)
	owner.put_in_l_hand(left_flame)

/datum/discipline_power/thaumaturgy/path/flames/two/deactivate()
	. = ..()
	// Remove flame weapons safely without dropping them
	for(var/obj/item/lighter/conjured/flame/palm_of_flame/flame in owner.held_items)
		flame.discipline_delete()

//Campfire - Level 3
/datum/discipline_power/thaumaturgy/path/flames/three
	name = "Campfire"
	desc = "Summon enough flame that would be in a campfire, and hurl it from your hands."

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

// TODO : add a botch where the user gets set on fire instead. these abilities should be strong - as they're acquired mid-round through 'jobby' activities, but they need 'magical accident' drawbacks
/datum/discipline_power/thaumaturgy/path/flames/three/activate(mob/living/target)
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
	cooldown_length = 20 SECONDS // remind me to increase this when pr is published
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

	var/turf/center = get_turf(target)

	// minimum one tile away from the center, maximum 2 tiles away from the center
	var/area_range = clamp(success_count, 1, 3)

	// create the inferno warning on all affected turfs in area_range from center
	var/list/affected_turfs = list()
	for(var/turf/T in range(area_range, center))
		affected_turfs += T
		new /obj/effect/temp_visual/inferno_warning(T)
	owner.visible_message(span_warning("Sparks begin to fly and the temperature begins to climb... what could be happening?!"))

	if(!do_after(owner, 4 SECONDS))
		to_chat(owner, span_warning("Your firestorm casting was interrupted!"))
		for(var/turf/T in affected_turfs) // delete all inferno warnings if casting was interrupted
			for(var/obj/effect/temp_visual/inferno_warning/W in T)
				qdel(W)
		return

	// damage dealt to those standing in the zone is based on successes and so are the fire stacks
	var/base_damage = 20 + (success_count * 5) + owner.thaum_damage_plus + owner.get_total_mentality()
	var/fire_stacks_amount = 3 + success_count
	var/ignite_chance = min(60 + (success_count * 10), 95) // 60% base, +10% per success, max 95%

	// casting succeeded
	for(var/turf/T in affected_turfs)
		// remove inferno warning and insert the actual fire objects
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
			to_chat(owner, span_bolddanger("Your firestorm burns with modest intensity."))
		if(2)
			to_chat(owner, span_bolddanger("Your firestorm rages with considerable power."))
		if(3 to INFINITY)
			to_chat(owner, span_bolddanger("Your firestorm burns with devastating supernatural fury!"))

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
	// pulsing animation
	animate(src, alpha = 50, time = 10, loop = -1)
	animate(alpha = 200, time = 10)

	// warning message sent to mobs that stand on the tile
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
		if(prob(10))
			var/target_turf = get_turf(L)
			new /obj/effect/fire(target_turf)
		L.visible_message(span_danger("[target] is struck by supernatural flames!"), span_userdanger("You are burned by supernatural fire!"))
		playsound(get_turf(target), 'modular_tfn/modules/paths/sounds/fireball.ogg', 50, TRUE)
