/datum/discipline/path/flames
	name = "Lure of Flames"
	desc = "A mystical path of Thaumaturgy that allows the summoning of fire and flame. Violates Masquerade."
	icon_state = "flames"
	power_type = /datum/discipline_power/path/flames

/datum/discipline_power/path/flames
	name = "Lure of Flames Power Name"
	desc = "Lure of Flames Power Description"

	effect_sound = 'modular_tfn/modules/paths/sounds/fireball.ogg'

// hand of flame
// flame bolt
// pillar of fire
// engulf
// firestorm

// Hand of Flame lighter item
/obj/item/lighter/hand_of_flame
	name = "hand of flame"
	desc = "Your hand burns with supernatural fire."
	icon = 'code/modules/wod13/32x48.dmi'
	icon_state = "fire"
	inhand_icon_state = "fire"
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
	playsound(src, 'modular_tfn/modules/paths/sounds/fireball.ogg', 50, TRUE)

/obj/item/lighter/hand_of_flame/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		// Chance to ignite target
		if(prob(25))
			L.adjust_fire_stacks(1)
			L.IgniteMob()
		playsound(src, 'modular_tfn/modules/paths/sounds/fireball.ogg', 25, TRUE)

//HAND OF FLAME - Level 1
/datum/discipline_power/path/flames/one
	name = "Hand of Flame"
	desc = "Ignite your hands with supernatural fire, adding burn damage to your punches."

	level = 1

	check_flags = DISC_CHECK_CAPABLE
	violates_masquerade = TRUE

	toggled = TRUE
	duration_length = 6 TURNS

	grouped_powers = list(
		/datum/discipline_power/path/flames/two,
		/datum/discipline_power/path/flames/three,
		/datum/discipline_power/path/flames/four,
		/datum/discipline_power/path/flames/five
	)

/datum/discipline_power/path/flames/one/activate()
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/lighter/hand_of_flame(owner))
	owner.put_in_l_hand(new /obj/item/lighter/hand_of_flame(owner))
	ADD_TRAIT(owner, TRAIT_NONMASQUERADE, TRAUMA_TRAIT)

/datum/discipline_power/path/flames/one/deactivate()
	. = ..()
	// Remove flame weapons
	for(var/obj/item/lighter/hand_of_flame/flame in owner.held_items)
		qdel(flame)
	REMOVE_TRAIT(owner, TRAIT_NONMASQUERADE, TRAUMA_TRAIT)

//FLAME BOLT - Level 2
/datum/discipline_power/path/flames/two
	name = "Flame Bolt"
	desc = "Hurl a bolt of supernatural fire at your target."

	level = 2
	cooldown_length = 1 SECONDS
	violates_masquerade = TRUE
	range = 7
	target_type = TARGET_LIVING

	grouped_powers = list(
		/datum/discipline_power/path/flames/one,
		/datum/discipline_power/path/flames/three,
		/datum/discipline_power/path/flames/four,
		/datum/discipline_power/path/flames/five
	)

/datum/discipline_power/path/flames/two/activate(mob/living/target)
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
/datum/discipline_power/path/flames/three
	name = "Pillar of Fire"
	desc = "Summon a towering pillar of flame from the ground beneath your target."

	level = 3
	cooldown_length = 10 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 7

	grouped_powers = list(
		/datum/discipline_power/path/flames/one,
		/datum/discipline_power/path/flames/two,
		/datum/discipline_power/path/flames/four,
		/datum/discipline_power/path/flames/five
	)

/datum/discipline_power/path/flames/three/activate(mob/living/target)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	// Create visual effect using standard temp visual instead of undefined type
	new /obj/effect/temp_visual/dir_setting/firing_effect(target_turf)

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
/datum/discipline_power/path/flames/four
	name = "Engulf"
	desc = "Surround your target in a raging inferno, dealing continuous burn damage."

	level = 4
	cooldown_length = 10 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 7

	grouped_powers = list(
		/datum/discipline_power/path/flames/one,
		/datum/discipline_power/path/flames/two,
		/datum/discipline_power/path/flames/three,
		/datum/discipline_power/path/flames/five
	)

/datum/discipline_power/path/flames/four/activate(mob/living/target)
	. = ..()
	if(!target)
		return

	// Initial damage
	var/damage_amount = 30 + owner.thaum_damage_plus + owner.get_total_mentality()
	target.adjustFireLoss(damage_amount)

	// Heavy fire stacks and ignition
	target.adjust_fire_stacks(8)
	target.IgniteMob()

	// Add burning effect using timer instead of undefined component
	addtimer(CALLBACK(src, PROC_REF(engulf_tick), target), 1 SECONDS)

	to_chat(target, span_userdanger("You are engulfed in supernatural flames!"))
	playsound(get_turf(target), effect_sound, 75, TRUE)

/datum/discipline_power/path/flames/four/proc/engulf_tick(mob/living/target)
	if(!target || target.stat == DEAD)
		return

	target.adjustFireLoss(5)
	// Schedule next tick for 15 seconds total duration
	var/static/tick_count = 0
	tick_count++
	if(tick_count < 15)
		addtimer(CALLBACK(src, PROC_REF(engulf_tick), target), 1 SECONDS)
	else
		tick_count = 0

//FIRESTORM - Level 5
/datum/discipline_power/path/flames/five
	name = "Firestorm"
	desc = "Unleash a devastating storm of fire that affects multiple targets in an area."

	level = 5
	cooldown_length = 20 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 10

	grouped_powers = list(
		/datum/discipline_power/path/flames/one,
		/datum/discipline_power/path/flames/two,
		/datum/discipline_power/path/flames/three,
		/datum/discipline_power/path/flames/four
	)

/datum/discipline_power/path/flames/five/activate(atom/target)
	. = ..()
	// Add 4 second casting time
	to_chat(owner, span_notice("You begin channeling a devastating firestorm..."))
	if(!do_after(owner, 4 SECONDS))
		to_chat(owner, span_warning("Your firestorm casting was interrupted!"))
		return
	var/turf/center = get_turf(target)
	var/list/affected_turfs = list()
	// Get 4x4 area around target (2 tiles in each direction from center)
	for(var/turf/T in range(2, center))
		affected_turfs += T
		new /obj/effect/fire(T)

	// Create visual effects and deal damage
	for(var/turf/T in affected_turfs)
		// Use standard temp visual instead of undefined type
		new /obj/effect/temp_visual/dir_setting/firing_effect(T)

		// Damage all mobs on each turf
		for(var/mob/living/L in T)
			if(L == owner) // Don't damage self
				continue

			var/damage_amount = 35 + owner.thaum_damage_plus + owner.get_total_mentality()
			L.adjustFireLoss(damage_amount)

			// High chance to ignite
			if(prob(80))
				L.adjust_fire_stacks(5)
				L.IgniteMob()

			to_chat(L, span_userdanger("You are caught in a supernatural firestorm!"))

	playsound(center, effect_sound, 100, TRUE)
	owner.visible_message(span_danger("[owner] unleashes a devastating firestorm!"))

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
		if(prob(30))
			L.adjust_fire_stacks(2)
			L.IgniteMob()

		// Visual effects
		L.visible_message(span_danger("[target] is struck by supernatural flames!"), span_userdanger("You are burned by supernatural fire!"))
		new /obj/effect/fire(get_turf(target))
		// Sound effect
		playsound(get_turf(target), 'modular_tfn/modules/paths/sounds/fireball.ogg', 50, TRUE)

/obj/projectile/flames/flamebolt/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		// Chance to ignite target
		if(prob(30))
			L.adjust_fire_stacks(2)
			L.IgniteMob()
