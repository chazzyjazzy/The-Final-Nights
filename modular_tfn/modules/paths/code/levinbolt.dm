/datum/discipline/path/levinbolt
	name = "Path of the Levinbolt"
	desc = "A rudimentary path of Thaumaturgy that allows the manipulation of lightning. Violates Masquerade."
	icon_state = "levinbolt"
	power_type = /datum/discipline_power/thaumaturgy/path/levinbolt

/datum/discipline_power/thaumaturgy/path/levinbolt
	name = "Path of the Levinbolt Power Name"
	desc = "Path of the Levinbolt Power Description"

	effect_sound = 'sound/magic/lightningbolt.ogg'


// spark
// illuminate
// power array
// zeus' fury
// eye of the storm

// sourced from the wiki and the revised tremere clanbook

//SPARK - Level 1
/datum/discipline_power/thaumaturgy/path/levinbolt/one
	name = "Spark"
	desc = "Generate a small electrical discharge upon being struck."

	level = 1
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_CONSCIOUS
	violates_masquerade = FALSE
	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/levinbolt/three
	)
	// storing original light values to control mobs lighting when theyre charged by electricity (dots one, three and five)
	var/original_light_range = 0
	var/original_light_power = 0
	var/original_light_color = null
	var/original_light_on = FALSE

//when the owner is attacked by mob/living, mob/living has a 30% chance (or maybe a roll, or maybe more) to suffer a small stun. probably need to use signals, but there doesnt seem to be an appropriate one.
// todo : check /tg/ for appropriate signals, implement them

/datum/discipline_power/thaumaturgy/path/levinbolt/one/activate()
	. = ..()
	if(.)
		RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(spark_counter))

		// Store original light values
		original_light_range = owner.light_range
		original_light_power = owner.light_power
		original_light_color = owner.light_color
		original_light_on = owner.light_on

		// Apply electric lighting effect
		owner.set_light_range(2)
		owner.set_light_power(1)
		owner.set_light_color(COLOR_WHITE) // Electric blue color
		owner.set_light_on(TRUE)


/datum/discipline_power/thaumaturgy/path/levinbolt/one/deactivate()
	. = ..()
	UnregisterSignal(owner, COMSIG_ATOM_ATTACKBY)
	// Restore original lighting
	owner.set_light_range(original_light_range)
	owner.set_light_power(original_light_power)
	owner.set_light_color(original_light_color)
	owner.set_light_on(original_light_on)

/datum/discipline_power/thaumaturgy/path/levinbolt/one/proc/spark_counter(mob/source, obj/item/weapon, mob/living/attacker)
	if(prob(30))
		attacker.Jitter(2)
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			H.electrocution_animation(40)
		attacker.emote("me", EMOTE_VISIBLE, "is electrocuted!")
		attacker.Stun(3 SECONDS)

//ILLUMINATE - Level 2
/datum/discipline_power/thaumaturgy/path/levinbolt/two
	name = "Illuminate"
	desc = "Surge a moderate amount of energy into your hand."
	level = 2
	violates_masquerade = TRUE
	toggled = TRUE
	duration_length = 2 TURNS

/obj/item/lighter/levinbolt_arm
	name = "Illuminate"
	desc = "Your arm surges with electricity!"
	icon = 'modular_tfn/modules/paths/icons/paths.dmi'
	icon_state = "illuminate" // TODO SPRITES
	inhand_icon_state = "illuminate" // TODO SPRITES
	lefthand_file = 'modular_tfn/modules/paths/icons/paths_inhand_lefthand.dmi'
	righthand_file = 'modular_tfn/modules/paths/icons/paths_inhand_righthand.dmi'
	force = 20
	damtype = BURN
	lit = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = COLOR_WHITE
	light_on = TRUE

/obj/item/lighter/levinbolt_arm/Initialize(mapload)
	. = ..()
	set_light_on(TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/two/activate(mob/living/target)
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/lighter/levinbolt_arm(owner))
	owner.put_in_l_hand(new /obj/item/lighter/levinbolt_arm(owner))

/datum/discipline_power/thaumaturgy/path/levinbolt/two/deactivate()
	. = ..()
	// Remove levinbolt arm weapons
	for(var/obj/item/lighter/levinbolt_arm/illuminate in owner.held_items)
		qdel(illuminate)

// TODO: More powerful than spark, this should discharge a greater amount of energy around the user, stunning and also damaging attackers. (Visible to all)
//POWER ARRAY - Level 3
/datum/discipline_power/thaumaturgy/path/levinbolt/three
	name = "Power Array"
	desc = "Discharge a greater amount of energy around yourself."

	level = 3
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_CONSCIOUS
	violates_masquerade = FALSE
	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/levinbolt/one
	)
	// storing original light values to control mobs lighting when theyre charged by electricity (dots one, three and five)
	var/original_light_range = 0
	var/original_light_power = 0
	var/original_light_color = null
	var/original_light_on = FALSE

/datum/discipline_power/thaumaturgy/path/levinbolt/three/activate()
	. = ..()
	if(.)
		RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(power_array_counter))

		// Store original light values
		original_light_range = owner.light_range
		original_light_power = owner.light_power
		original_light_color = owner.light_color
		original_light_on = owner.light_on

		// Apply electric lighting effect
		owner.set_light_range(2)
		owner.set_light_power(1)
		owner.set_light_color(COLOR_WHITE) // Electric blue color
		owner.set_light_on(TRUE)
		//owner.set_light_range_power_color(2, 1, COLOR_WHITE) -- ??


/datum/discipline_power/thaumaturgy/path/levinbolt/three/deactivate()
	. = ..()
	UnregisterSignal(owner, COMSIG_ATOM_ATTACKBY)
	// Restore original lighting
	owner.set_light_range(original_light_range)
	owner.set_light_power(original_light_power)
	owner.set_light_color(original_light_color)
	owner.set_light_on(original_light_on)

/datum/discipline_power/thaumaturgy/path/levinbolt/three/proc/power_array_counter(mob/source, obj/item/weapon, mob/living/attacker)
	if(prob(30))
		attacker.emote("scream")
		attacker.emote("me", null, "is electrocuted!")
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			H.electrocution_animation(40)
		attacker.Jitter(2)
		attacker.Stun(3 SECONDS)
		attacker.adjustFireLoss(30)

//ZEUS' FURY - Level 4 - Enhanced with Chain Lightning
/datum/discipline_power/thaumaturgy/path/levinbolt/four
	name = "Zeus' Fury"
	desc = "Build up energy and direct it as arcs of lightning that chain between targets."

	level = 4
	cooldown_length = 30 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 7

	var/static/mutable_appearance/electric_halo

/datum/discipline_power/thaumaturgy/path/levinbolt/four/activate(mob/living/target)
	. = ..()

	// Check if we failed the roll (botch or failure already handled by parent)
	if(success_count <= 0)
		return

	if(!target)
		to_chat(owner, span_warning("You need a target to direct your fury at!"))
		return

	if(get_dist(owner, target) > range)
		to_chat(owner, span_warning("[target.p_theyre(TRUE)] is too far away!"))
		return

	// Start the charging process
	owner.visible_message(span_danger("[owner.name] crackles with building electrical energy!"),
		span_danger("You begin channeling Zeus' fury, electricity arcing around your body!"))

	// Add visual effects during charge
	electric_halo = electric_halo || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	owner.add_overlay(electric_halo)

	// Allow movement during charge but require 3 seconds focus
	if(do_after(owner, 3 SECONDS, target, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM)))
		if(get_dist(owner, target) <= range)
			execute_zeus_fury(target)
		else
			cancel_fury("Target moved out of range.")
	else
		cancel_fury("Channeling interrupted.")

/datum/discipline_power/thaumaturgy/path/levinbolt/four/proc/execute_zeus_fury(mob/living/primary_target)
	owner.cut_overlay(electric_halo)

	// Use success_count from parent class for chain bounces and damage
	var/max_bounces = success_count // Each success = one additional bounce
	var/bolt_damage = 20 + (success_count * 8) // Base 20 + 8 per success

	// Success-based flavor text
	switch(success_count)
		if(1)
			owner.visible_message(span_danger("[owner.name] releases a crackling bolt of lightning!"),
				span_danger("You release a modest arc of electrical energy!"))
		if(2 to 3)
			owner.visible_message(span_bolddanger("[owner.name] unleashes a powerful chain of lightning!"),
				span_bolddanger("You channel Zeus' power, lightning arcing between targets!"))
		if(4 to 5)
			owner.visible_message(span_reallybig(span_bolddanger("[owner.name] commands the very storm itself!")),
				span_reallybig(span_bolddanger("You become a conduit for divine wrath!")))
		else // 6+ successes - legendary
			owner.visible_message(span_reallybig(span_bolddanger("The air itself SCREAMS as [owner.name] becomes lightning incarnate!")),
				span_reallybig(span_bolddanger("UNLIMITED POWER courses through your being!")))

	playsound(get_turf(owner), 'sound/magic/lightningbolt.ogg', min(50 + (success_count * 10), 100), TRUE, extrarange = success_count)

	// Create the initial lightning bolt to primary target
	owner.Beam(primary_target, icon_state="lightning[rand(1,12)]", time = (5 + success_count))

	// Start the chain lightning sequence
	chain_bolt(owner, primary_target, bolt_damage, max_bounces, list(owner))

/datum/discipline_power/thaumaturgy/path/levinbolt/four/proc/chain_bolt(atom/origin, mob/living/current_target, bolt_energy, bounces_left, list/already_hit)
	current_target.electrocute_act(bolt_energy, "Zeus' Fury", flags = SHOCK_NOGLOVES)
	playsound(get_turf(current_target), 'sound/magic/lightningshock.ogg', 60, TRUE)

	// Additional effects scale with success count
	current_target.Jitter(20 + (success_count * 5))
	if(ishuman(current_target))
		var/mob/living/carbon/human/H = current_target
		H.electrocution_animation(40 + (success_count * 10))

	// Better chance to stun with more successes
	var/stun_chance = min(30 + (success_count * 15), 85)
	if(bolt_energy >= 20 && prob(stun_chance))
		var/stun_duration = (1 + success_count) SECONDS
		current_target.Paralyze(stun_duration)
		current_target.visible_message(span_warning("[current_target] convulses violently from the electrical shock!"))

	// Add current target to already hit list
	already_hit += current_target

	// If no bounces left, end the chain
	if(bounces_left <= 0)
		return

	// Find next target for chain lightning
	var/list/possible_targets = list()
	for(var/mob/living/L in view(range, current_target))
		if(L in already_hit) // Don't hit the same target twice
			continue
		possible_targets += L

	if(!possible_targets.len)
		return // No more valid targets

	// Pick closest target for more realistic chain lightning
	var/mob/living/next_target = null
	var/shortest_distance = INFINITY
	for(var/mob/living/potential in possible_targets)
		var/distance = get_dist(current_target, potential)
		if(distance < shortest_distance)
			shortest_distance = distance
			next_target = potential

	if(next_target)
		// Slight delay for dramatic effect, shorter with more successes (more control)
		var/chain_delay = max(5 - success_count, 1)
		addtimer(CALLBACK(src, PROC_REF(continue_chain), current_target, next_target, bolt_energy, bounces_left, already_hit), chain_delay)

/datum/discipline_power/thaumaturgy/path/levinbolt/four/proc/continue_chain(atom/origin, mob/living/next_target, bolt_energy, bounces_left, list/already_hit)
	// Create lightning arc to next target
	origin.Beam(next_target, icon_state="lightning[rand(1,12)]", time = (5 + success_count))

	// With more successes, energy loss per bounce is reduced (better control)
	var/energy_retention = 0.8 + (success_count * 0.05) // 80% base, up to 110% with many successes
	var/reduced_energy = max(bolt_energy * energy_retention, 10) // Minimum 10 damage

	// Continue the chain
	chain_bolt(origin, next_target, reduced_energy, bounces_left - 1, already_hit)

/datum/discipline_power/thaumaturgy/path/levinbolt/four/proc/cancel_fury(reason)
	if(electric_halo)
		owner.cut_overlay(electric_halo)


	to_chat(owner, span_warning("Zeus' Fury fizzles out. [reason]"))

// TODO: Combination of some disciplines. It should flashbang everyone upon being activated, and allow them to shock others dramatically with their hand for a short duration.
//EYE OF THE STORM - Level 5
/datum/discipline_power/thaumaturgy/path/levinbolt/five
	name = "Eye of the Storm"
	desc = "Become charged with an incredible amount of energy."

	level = 5
	cooldown_length = 60 SECONDS
	violates_masquerade = TRUE

/datum/discipline_power/thaumaturgy/path/levinbolt/five/activate(atom/target)
	. = ..()
