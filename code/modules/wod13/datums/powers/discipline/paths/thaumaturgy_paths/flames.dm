/datum/discipline/path/flames
	name = "Lure of Flames"
	desc = "A mystical path of Thaumaturgy that allows the summoning of fire and flame. Violates Masquerade."
	icon_state = "flames"
	power_type = /datum/discipline_power/flames

/datum/discipline_power/flames
	name = "Lure of Flames Power Name"
	desc = "Lure of Flames Power Description"

	effect_sound = 'code/modules/wod13/sounds/fireball.ogg'

// hand of flame

// flame bolt
// pillar of fire
// engulf
// firestorm

//HAND OF FLAME - Level 1
/datum/discipline_power/flames/one
	name = "Hand of Flame"
	desc = "Ignite your hands with supernatural fire, adding burn damage to your punches."

	level = 1

	check_flags = DISC_CHECK_CAPABLE
	violates_masquerade = TRUE

	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/flames/two,
		/datum/discipline_power/flames/three,
		/datum/discipline_power/flames/four,
		/datum/discipline_power/flames/five
	)

/datum/discipline_power/flames/one/activate()
	. = ..()
	owner.dna.species.attack_sound = 'code/modules/wod13/sounds/fireball.ogg'
	owner.dna.species.punchdamagelow += 3
	owner.dna.species.punchdamagehigh += 3
	// Add burn damage component to punches
	owner.potential = 1
	ADD_TRAIT(owner, TRAIT_NONMASQUERADE, TRAUMA_TRAIT)

/datum/discipline_power/flames/one/deactivate()
	. = ..()
	owner.dna.species.attack_sound = initial(owner.dna.species.attack_sound)
	owner.remove_overlay(FLAMES_LAYER)
	owner.dna.species.punchdamagelow -= 3
	owner.dna.species.punchdamagehigh -= 3
	owner.potential = 0
	REMOVE_TRAIT(owner, TRAIT_NONMASQUERADE, TRAUMA_TRAIT)

//FLAME BOLT - Level 2
/datum/discipline_power/flames/two
	name = "Flame Bolt"
	desc = "Hurl a bolt of supernatural fire at your target."

	level = 2
	cooldown_length = 1 SECONDS
	violates_masquerade = TRUE

	grouped_powers = list(
		/datum/discipline_power/flames/one,
		/datum/discipline_power/flames/three,
		/datum/discipline_power/flames/four,
		/datum/discipline_power/flames/five
	)

/datum/discipline_power/flames/two/activate(mob/living/target)
	. = ..()
	var/turf/start = get_turf(owner)
	var/obj/projectile/flames/flamebolt/H = new(start)
	H.firer = owner
	H.damage = 20 + owner.thaum_damage_plus + owner.get_total_mentality()
	H.preparePixelProjectile(target, start)
	H.level = 2
	H.fire(direct_target = target)
	to_chat(target, span_danger("A bolt of searing flame flies toward you!"))

//PILLAR OF FIRE - Level 3
/datum/discipline_power/flames/three
	name = "Pillar of Fire"
	desc = "Summon a towering pillar of flame from the ground beneath your target."

	level = 3
	cooldown_length = 10 SECONDS
	violates_masquerade = TRUE

	grouped_powers = list(
		/datum/discipline_power/flames/one,
		/datum/discipline_power/flames/two,
		/datum/discipline_power/flames/four,
		/datum/discipline_power/flames/five
	)

/datum/discipline_power/flames/three/activate(mob/living/target)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	// Create visual effect
	new /obj/effect/temp_visual/pillar_of_fire(target_turf)

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
/datum/discipline_power/flames/four
	name = "Engulf"
	desc = "Surround your target in a raging inferno, dealing continuous burn damage."

	level = 4
	cooldown_length = 30 SECONDS
	violates_masquerade = TRUE

	grouped_powers = list(
		/datum/discipline_power/flames/one,
		/datum/discipline_power/flames/two,
		/datum/discipline_power/flames/three,
		/datum/discipline_power/flames/five
	)

/datum/discipline_power/flames/four/activate(mob/living/target)
	. = ..()
	if(!target)
		return

	// Initial damage
	var/damage_amount = 30 + owner.thaum_damage_plus + owner.get_total_mentality()
	target.adjustFireLoss(damage_amount)

	// Heavy fire stacks and ignition
	target.adjust_fire_stacks(8)
	target.IgniteMob()

	// Add burning effect component for continuous damage
	target.AddComponent(/datum/component/burning_engulf, duration = 15 SECONDS, tick_damage = 5)

	to_chat(target, span_userdanger("You are engulfed in supernatural flames!"))
	playsound(get_turf(target), effect_sound, 75, TRUE)

//FIRESTORM - Level 5
/datum/discipline_power/flames/five
	name = "Firestorm"
	desc = "Unleash a devastating storm of fire that affects multiple targets in an area."

	level = 5
	cooldown_length = 60 SECONDS
	violates_masquerade = TRUE

	grouped_powers = list(
		/datum/discipline_power/flames/one,
		/datum/discipline_power/flames/two,
		/datum/discipline_power/flames/three,
		/datum/discipline_power/flames/four
	)

/datum/discipline_power/flames/five/activate(atom/target)
	. = ..()
	var/turf/center = get_turf(target)
	if(!center)
		return

	var/list/affected_turfs = list()
	var/range = 3

	// Get all turfs in range
	for(var/turf/T in range(range, center))
		affected_turfs += T

	// Create visual effects and deal damage
	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/firestorm(T)

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

// Projectile for Flame Bolt
/obj/projectile/flames
	name = "flame"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "fireball"
	damage_type = BURN

/obj/projectile/flames/flamebolt
	name = "flame bolt"
	damage = 20

/obj/projectile/flames/flamebolt/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		// Chance to ignite target
		if(prob(30))
			L.adjust_fire_stacks(2)
			L.IgniteMob()
