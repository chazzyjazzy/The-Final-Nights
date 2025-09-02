/datum/discipline/path/levinbolt
	name = "Path of the Levinbolt"
	desc = "A rudimentary path of Thaumaturgy that allows the manipulation of lightning. Violates Masquerade."
	icon_state = "levinbolt"
	power_type = /datum/discipline_power/thaumaturgy/path/levinbolt

/datum/discipline_power/thaumaturgy/path/levinbolt
	name = "Path of the Levinbolt Power Name"
	desc = "Path of the Levinbolt Power Description"

	effect_sound = 'sound/magic/lightningbolt.ogg'


// Base shared procedure for all levinbolt powers
/datum/discipline_power/thaumaturgy/path/levinbolt/proc/levinbolt_target_click(mob/source, atom/target, params, include_radio_effects = FALSE)
	if(!active || !toggled)
		return

	if(!target || get_dist(owner, target) > 1)
		return

	// Radio effects (only for level 3)
	if(include_radio_effects && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/disabled_any = FALSE
		for(var/obj/item/I in H.get_all_slots())
			if(istype(I, /obj/item/p25radio))
				var/obj/item/p25radio/radio = I
				if(radio.powered)
					radio.powered = FALSE
					to_chat(H, span_warning("Your [I.name] crackles violently and powers down!"))
					to_chat(owner, span_notice("You surge electricity into [H]'s [I.name], disabling it!"))
					playsound(H, 'sound/effects/sparks4.ogg', 60, TRUE)
					disabled_any = TRUE
				else
					radio.powered = TRUE
					to_chat(H, span_warning ("Electricity surges into your radio - turning it on!"))
					to_chat(owner, span_notice("You surge electricity into [H]'s [I.name], turning it on!"))
					playsound(H, 'sound/effects/sparks4.ogg', 60, TRUE)
					disabled_any = TRUE
		if(disabled_any)
			var/datum/effect_system/spark_spread/spark_system = new
			spark_system.set_up(5, 1, get_turf(H))
			spark_system.start()
			return TRUE

	// Handle cargo express computer
	if(istype(target, /obj/machinery/computer/cargo/express))
		var/obj/machinery/computer/cargo/express/cargo_comp = target
		if(cargo_comp.locked == 0)
			cargo_comp.locked = 1
		else
			cargo_comp.locked = 0

		// Visual and audio effects
		var/datum/effect_system/spark_spread/spark_system = new
		spark_system.set_up(3, 1, get_turf(target))
		spark_system.start()
		playsound(target, 'sound/effects/sparks4.ogg', 50, TRUE)

		// Different messages based on level
		if(include_radio_effects) // Level 3
			to_chat(owner, span_notice("You send electrical sparks into [target], unlocking its systems!"))
		else // Level 1
			to_chat(owner, span_notice("You send electrical sparks into [target]!"))

		owner.visible_message(span_warning("[owner] sends sparks of electricity into [target]!"))
		return TRUE

	// Handle fusebox
	if(istype(target, /obj/fusebox))
		var/obj/fusebox/fuse = target

		// Break the fusebox
		fuse.damaged += 101
		fuse.check_damage(owner, TRUE)

		// Visual and audio effects
		var/datum/effect_system/spark_spread/spark_system = new
		spark_system.set_up(5, 1, get_turf(target))
		spark_system.start()
		playsound(target, 'sound/effects/sparks2.ogg', 75, TRUE)

		to_chat(owner, span_notice("You overload [target] with electrical energy!"))
		owner.visible_message(span_warning("[owner] sends a surge of electricity into [target]!"))

		// Small chance to electrocute the user too
		if(prob(15))
			owner.electrocute_act(10, target, siemens_coeff = 1, flags = NONE)
			to_chat(owner, span_warning("Some of the electrical feedback hits you!"))

		return TRUE

	return FALSE


// spark
// illuminate
// power array
// zeus' fury
// eye of the storm

// sourced from the wiki and the revised tremere clanbook

//SPARK - Level 1
/datum/discipline_power/thaumaturgy/path/levinbolt/one
	name = "Spark"
	desc = "Generate a small electrical discharge upon being struck, or target objects to disrupt their electronics."

	level = 1
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_CONSCIOUS
	violates_masquerade = FALSE
	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/levinbolt/three,
		/datum/discipline_power/thaumaturgy/path/levinbolt/five
	)
	// storing original light values to control mobs lighting when theyre charged by electricity (dots one, three and five)
	var/original_light_range = 0
	var/original_light_power = 0
	var/original_light_color = null
	var/original_light_on = FALSE
	var/static/mutable_appearance/electricity

/datum/discipline_power/thaumaturgy/path/levinbolt/one/activate()
	. = ..()
	if(!active)
		return
	RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(spark_counter))
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(spark_target_click))
	electricity = electricity || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	owner.add_overlay(electricity)

	// Set up overlay lighting component for electric glow
	owner.light_system = MOVABLE_LIGHT
	owner.AddComponent(/datum/component/overlay_lighting, 2, 1, "#f1fdfd", TRUE)
	to_chat(owner, span_notice("Small sparks of electricity begin crackling around you! Youn can now disable certain electrical systems with just a touch - and attackers will sometimes feel a slight shock."))

/datum/discipline_power/thaumaturgy/path/levinbolt/one/deactivate()
	. = ..()
	UnregisterSignal(owner, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	owner.cut_overlay(electricity)
	// Remove the lighting component
	var/datum/component/overlay_lighting/light_comp = owner.GetComponent(/datum/component/overlay_lighting)
	if(light_comp)
		qdel(light_comp)

	// Reset light system
	owner.light_system = initial(owner.light_system)
	to_chat(owner, span_notice("The electricity around you fades away."))

/datum/discipline_power/thaumaturgy/path/levinbolt/one/proc/spark_counter(mob/source, obj/item/weapon, mob/living/attacker)
	if(prob(30))
		attacker.Jitter(2)
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			H.electrocution_animation(40)
		attacker.emote("me", EMOTE_VISIBLE, "is electrocuted!")
		attacker.Stun(3 SECONDS)

/datum/discipline_power/thaumaturgy/path/levinbolt/one/proc/spark_target_click(mob/source, atom/target, params)
	return levinbolt_target_click(source, target, params, FALSE)

//ILLUMINATE - Level 2
/datum/discipline_power/thaumaturgy/path/levinbolt/two
	name = "Illuminate"
	desc = "Surge a moderate amount of energy into your hand."
	level = 2
	violates_masquerade = TRUE
	toggled = TRUE
	duration_length = 2 TURNS



/datum/discipline_power/thaumaturgy/path/levinbolt/two/activate(mob/living/target)
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/lighter/conjured/levinbolt_arm(owner))
	owner.put_in_l_hand(new /obj/item/lighter/conjured/levinbolt_arm(owner))

/datum/discipline_power/thaumaturgy/path/levinbolt/two/deactivate()
	. = ..()
	// Remove levinbolt arm weapons
	for(var/obj/item/lighter/conjured/levinbolt_arm/illuminate in owner.held_items)
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
		/datum/discipline_power/thaumaturgy/path/levinbolt/one,
		/datum/discipline_power/thaumaturgy/path/levinbolt/five
	)
	// storing original light values to control mobs lighting when theyre charged by electricity (dots one, three and five)
	var/original_light_range = 0
	var/original_light_power = 0
	var/original_light_color = null
	var/original_light_on = FALSE
	var/static/mutable_appearance/electricity2


/datum/discipline_power/thaumaturgy/path/levinbolt/three/activate()
	. = ..()
	if(!active)
		return
	RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(power_array_counter))
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(powerarray_target_click))

	electricity2 = electricity2 || mutable_appearance('icons/effects/effects.dmi', "electricity2", EFFECTS_LAYER)
	owner.add_overlay(electricity2)
	// Set up stronger overlay lighting component for more intense electric glow
	owner.light_system = MOVABLE_LIGHT
	owner.AddComponent(/datum/component/overlay_lighting, 3, 2, "#e9ffff", TRUE)
	to_chat(owner, span_notice("Intense electricity surges around your entire body!"))


/datum/discipline_power/thaumaturgy/path/levinbolt/three/deactivate()
	. = ..()
	UnregisterSignal(owner, COMSIG_ATOM_ATTACKBY)
	owner.cut_overlay(electricity2)
	// Remove the lighting component
	var/datum/component/overlay_lighting/light_comp = owner.GetComponent(/datum/component/overlay_lighting)
	if(light_comp)
		qdel(light_comp)

	// Reset light system
	owner.light_system = initial(owner.light_system)
	to_chat(owner, span_notice("The electricity around your body dissipates."))

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

/datum/discipline_power/thaumaturgy/path/levinbolt/three/proc/powerarray_target_click(mob/source, atom/target, params)
	return levinbolt_target_click(source, target, params, TRUE)


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

//EYE OF THE STORM - Level 5
/datum/discipline_power/thaumaturgy/path/levinbolt/five
	name = "Eye of the Storm"
	desc = "Become charged with an incredible amount of energy."

	level = 5
	violates_masquerade = TRUE
	toggled = TRUE
	duration_length = 1 TURNS
	vitae_cost = 2

	var/lightning_timer
	var/spark_timer
	var/static/mutable_appearance/electricity3
	grouped_powers = list(
		/datum/discipline_power/thaumaturgy/path/levinbolt/one,
		/datum/discipline_power/thaumaturgy/path/levinbolt/three
	)


/datum/discipline_power/thaumaturgy/path/levinbolt/five/activate(atom/target)
	. = ..()
	if(!.)
		return
	add_electricity_overlay()
	RegisterSignal(owner, COMSIG_CLICK, PROC_REF(storm_target_click))
	RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(storm_counter))
	spark_timer = addtimer(CALLBACK(src, PROC_REF(create_sparks)), 2 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)
	lightning_timer = addtimer(CALLBACK(src, PROC_REF(fire_lightning_bolt)), 5 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)

	// Visual and audio feedback
	owner.visible_message(span_danger("[owner] becomes surrounded by crackling electrical energy!"))
	to_chat(owner, span_notice("You feel incredible electrical power coursing through your body!"))
	playsound(owner, 'sound/effects/sparks4.ogg', 75, TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/proc/add_electricity_overlay()
	if(!owner || electricity3)
		return
	electricity3 = electricity3 || mutable_appearance('icons/effects/effects.dmi', "electricity2", EFFECTS_LAYER)
	owner.add_overlay(electricity3)
	owner.light_system = MOVABLE_LIGHT
	owner.AddComponent(/datum/component/overlay_lighting, 5, 4, "#e9ffff", TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/proc/remove_electricity_overlay()
	if(!owner || !electricity3)
		return

	owner.cut_overlay(electricity3)
	QDEL_NULL(electricity3)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/proc/create_sparks()
	if(!owner)
		return

	var/datum/effect_system/spark_spread/spark_system = new
	spark_system.set_up(rand(3,7), 1, get_turf(owner))
	spark_system.start()

	if(prob(50))
		playsound(owner, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg'), 40, TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/proc/fire_lightning_bolt()
	if(!owner)
		return

	var/list/potential_targets = list()
	for(var/mob/living/L in range(7, owner))
		if(L != owner && L.stat != DEAD)
			potential_targets += L

	if(!length(potential_targets))
		return

	var/mob/living/target = pick(potential_targets)

	owner.Beam(target, icon_state="lightning[rand(1,12)]", time = 10)

	target.adjustFireLoss(30)
	target.Jitter(25)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.electrocution_animation(50)

	if(prob(60))
		target.Stun(2 SECONDS)
		target.visible_message(span_warning("[target] convulses from the electrical shock!"))

	var/datum/effect_system/spark_spread/spark_system = new
	spark_system.set_up(8, 1, get_turf(target))
	spark_system.start()

	owner.visible_message(span_danger("Lightning arcs from [owner] to [target]!"))
	playsound(target, 'sound/magic/lightningshock.ogg', 75, TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/proc/storm_counter(mob/source, obj/item/weapon, mob/living/attacker)
	if(prob(60))
		attacker.Jitter(3)
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			H.electrocution_animation(60)
		attacker.emote("me", EMOTE_VISIBLE, "is violently electrocuted!")
		attacker.Stun(4 SECONDS)
		attacker.electrocute_act(rand(10,20), owner, siemens_coeff = 1, flags = NONE)
		var/datum/effect_system/spark_spread/spark_system = new
		spark_system.set_up(5, 1, get_turf(attacker))
		spark_system.start()
		playsound(attacker, 'sound/effects/sparks4.ogg', 60, TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/proc/storm_target_click(mob/source, atom/target, params)
	return levinbolt_target_click(source, target, params, TRUE)

/datum/discipline_power/thaumaturgy/path/levinbolt/five/deactivate()
	if(!owner)
		return

	remove_electricity_overlay()
	UnregisterSignal(owner, list(COMSIG_CLICK, COMSIG_ATOM_ATTACKBY))

	// Stop timers
	if(spark_timer)
		deltimer(spark_timer)
		spark_timer = null
	if(lightning_timer)
		deltimer(lightning_timer)
		lightning_timer = null

	owner.visible_message(span_notice("The electrical energy around [owner] dissipates."))
	to_chat(owner, span_notice("The storm within you calms."))

	. = ..()

/datum/discipline_power/thaumaturgy/path/levinbolt/five/Destroy()
	if(spark_timer)
		deltimer(spark_timer)
	if(lightning_timer)
		deltimer(lightning_timer)
	if(electricity3)
		QDEL_NULL(electricity3)
	. = ..()

