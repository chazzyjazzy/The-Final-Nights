#define TRAIT_MESMERIZED "mesmerized"

/datum/discipline/dominate
	name = "Dominate"
	desc = "Suppresses will of your targets and forces them to obey you, if their will is not more powerful than yours."
	icon_state = "dominate"
	power_type = /datum/discipline_power/dominate


/datum/discipline/dominate/post_gain()
	. = ..()
	if(level >= 5)
		var/obj/effect/proc_holder/spell/voice_of_god/voice_of_domination = new(owner)
		owner.mind.AddSpell(voice_of_domination)
		RegisterSignal(owner, COMSIG_MOB_EMOTE, PROC_REF(on_snap))

/datum/discipline/dominate/proc/on_snap(atom/source, datum/emote/emote_args)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(handle_snap), source, emote_args)

/datum/discipline/dominate/proc/handle_snap(atom/source, datum/emote/emote_args)
	var/list/emote_list = list("snap", "snap2", "snap3", "whistle")
	if(!emote_list.Find(emote_args.key))
		return
	for(var/mob/living/carbon/human/target in get_hearers_in_view(6, owner))
		var/mob/living/carbon/human/conditioner = target.conditioner?.resolve()
		if(conditioner != owner)
			continue
		switch(emote_args.key)
			if("snap")
				target.SetSleeping(0)
				target.silent = 3
				target.dir = get_dir(target, owner)
				target.emote("me", 1, "faces towards <b>[owner]</b> attentively.", TRUE)
				to_chat(target, span_danger("ATTENTION"))
			if("snap2")
				target.dir = get_dir(target, owner)
				target.Immobilize(50)
				target.emote("me",1,"flinches in response to <b>[owner]'s</b> snapping.", TRUE)
				to_chat(target, span_danger("HALT"))
			if("snap3")
				target.Knockdown(50)
				target.Immobilize(80)
				target.emote("me",1,"'s knees buckle under the weight of their body.",TRUE)
				target.do_jitter_animation(0.1 SECONDS)
				to_chat(target, span_danger("DROP"))
			if("whistle")
				target.apply_status_effect(STATUS_EFFECT_AWE, owner)
				to_chat(target, span_danger("HITHER"))


/datum/discipline_power/dominate
	name = "Dominate power name"
	desc = "Dominate power description"

	activate_sound = 'code/modules/wod13/sounds/dominate.ogg'
	var/domination_succeeded = FALSE
	var/mypower = 0
	var/theirpower = 0

/datum/discipline_power/dominate/activate(mob/living/target)
	. = ..()
	var/mob/living/carbon/human/dominate_target
	if(ishuman(target))
		dominate_target = target
		dominate_target.remove_overlay(MUTATIONS_LAYER)
		var/mutable_appearance/dominate_overlay = mutable_appearance('code/modules/wod13/icons.dmi', "dominate", -MUTATIONS_LAYER)
		dominate_overlay.pixel_z = 2
		dominate_target.overlays_standing[MUTATIONS_LAYER] = dominate_overlay
		dominate_target.apply_overlay(MUTATIONS_LAYER)
		dominate_target.face_atom(owner)
		to_chat(dominate_target, span_info("If someone is using Dominate to compel you to do something you are personally uncomfortable with as a player, you are allowed to ignore it. Follow the spirit of the dominate - not just the letter!"))
		addtimer(CALLBACK(dominate_target, TYPE_PROC_REF(/mob/living/carbon/human, post_dominate_checks), dominate_target), 2 SECONDS)
	return TRUE

/datum/discipline_power/dominate/proc/dominate_hearing_check(mob/living/carbon/human/owner, mob/living/target)
	var/list/hearers = get_hearers_in_view(8, owner)
	if(!(target in hearers))
		to_chat(owner, span_warning("[target] cannot hear you — they are too far or behind an obstruction."))
		return FALSE
	else
		to_chat(owner, span_info("[target] hears you clearly."))
		return TRUE

/datum/discipline_power/dominate/proc/dominate_check(mob/living/carbon/human/owner, mob/living/target, tiebreaker = FALSE, base_difficulty = 4)

	if(!ishuman(target))
		return FALSE

	mypower = SSroll.storyteller_roll(owner.get_total_social(), difficulty = base_difficulty, mobs_to_show_output = owner, numerical = TRUE)
	theirpower = SSroll.storyteller_roll(target.get_total_mentality(), difficulty = 6, mobs_to_show_output = target, numerical = TRUE)
	var/mob/living/carbon/human/conditioner = target.conditioner?.resolve()

	if(owner == conditioner)
		return TRUE

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.clan?.name == CLAN_GARGOYLE)
			theirpower -= 2

	if(target.conditioned)
		theirpower += 3

	if(mypower > theirpower && owner.generation <= target.generation)
		return TRUE

	return FALSE

/datum/movespeed_modifier/dominate
	multiplicative_slowdown = 5


//COMMAND
/datum/discipline_power/dominate/command
	name = "Command"
	desc = "Speak one word and force others to obey."

	level = 1

	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_LIVING

	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	duration_length = 3 SECONDS
	range = 7
	var/custom_command = "FORGET ABOUT IT"

/datum/discipline_power/dominate/command/pre_activation_checks(mob/living/target)  // this pre-check includes some special checks
	if(!dominate_hearing_check(owner, target)) // putting the hearing check into the pre_activation so that if the target cant hear you it doesnt consume blood and alerts you
		return FALSE

	to_chat(owner, span_info("Dominate 'Commands' may be only one word."))
	custom_command = tgui_input_text(owner, "Dominate Command", "What is your command?", encode = FALSE)

	if (!custom_command)
		return FALSE // No message, no dominate

	if(can_afford())
		if(length(splittext(custom_command, " ")) > 1)
			to_chat(owner, span_warning("Commands must be only ONE word!"))
			return FALSE

		if(dominate_check(owner, target, base_difficulty = 4))
			return TRUE
		else
			to_chat(owner, span_warning("[target] has resisted your domination!"))
			do_cooldown(TRUE)
			return FALSE
	else
		to_chat(owner, span_warning("You do not have enough blood to cast Dominate!"))
		return FALSE

/datum/discipline_power/dominate/command/activate(mob/living/target)
	. = ..()
	to_chat(owner, span_warning("You've successfully dominated [target]'s mind!"))
	owner.say(custom_command)
	to_chat(target, span_big("[custom_command]"))
	var/last_margin = mypower - theirpower
	switch(last_margin)
		if(1)
			to_chat(target,span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You feel compelled to [custom_command] with mild vigor and short duration."))
		if(2)
			to_chat(target,span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You feel compelled to [custom_command]."))
		if(3)
			to_chat(target,span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You feel compelled to [custom_command] with moderate vigor and extended duration."))
		if(4)
			to_chat(target,span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You feel compelled to [custom_command] with great vigor and long duration."))
		if(5)
			to_chat(target,span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You feel compelled to [custom_command] with supernatural vigor!"))
		else
			to_chat(target,span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You immediately and vigorously complete the will of the attacker - [custom_command]."))
	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))


//MESMERIZE
/datum/discipline_power/dominate/mesmerize
	name = "Mesmerize"
	desc = "Plant a hypnotic suggestion in a target's head that will repeatedly echo in their mind."

	level = 2

	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_LIVING

	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	range = 7
	var/dominate_succeeded = FALSE
	var/custom_message = ""
	var/successes_rolled
	var/mob/living/current_target
	var/datum/action/vampire/end_mesmerization/end_action

/datum/discipline_power/dominate/mesmerize/pre_activation_checks(mob/living/target)

	if(!dominate_hearing_check(owner, target))
		return FALSE

	// Check if target is already mesmerized
	if(HAS_TRAIT(target, TRAIT_MESMERIZED))
		to_chat(owner, span_warning("[target] is already under a hypnotic suggestion!"))
		return FALSE

	// Get custom hypnotic message from the user
	custom_message = tgui_input_text(owner, "Hypnotic Suggestion", "What hypnotic message will echo in their mind?", encode = FALSE)

	if (!custom_message)
		return FALSE // No message, no mesmerize

	if (HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		dominate_succeeded = TRUE
		successes_rolled = 5 // Maximum successes for trait holders
		return TRUE

	// Get the actual number of successes from domination check
	var/domination_result = dominate_check(owner, target, base_difficulty = 5)
	if(domination_result > 0)
		domination_succeeded = TRUE
		successes_rolled = domination_result
		return TRUE
	else
		domination_succeeded = FALSE
		successes_rolled = 0
		do_cooldown(cooldown_length)
		return FALSE

/datum/discipline_power/dominate/mesmerize/activate(mob/living/target)
	. = ..()

	target.anchored = TRUE
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_INCAPACITATED, TRAIT_GENERIC)
	if(do_mob(owner, target, 5 SECONDS))
		REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
		REMOVE_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
		target.anchored = FALSE
		to_chat(owner, span_warning("You've successfully planted a hypnotic suggestion in [target]'s mind!"))
		to_chat(target, span_info("An urging, subconcious thought has entered your mind. Youre not sure how this happened - but it keeps pulsing, forcing your conscious thought to bend toward it."))
		owner.say(custom_message)
		to_chat(target, span_hypnophrase(custom_message))
		SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))

		// Store current target
		current_target = target

		// Add mesmerize trait
		ADD_TRAIT(target, TRAIT_MESMERIZED, TRAIT_GENERIC)

		// Give the owner an action to end mesmerization
		end_action = new(owner, src)
		end_action.Grant(owner)

		// Start the recurring mesmerization effect
		start_mesmerization_cycle(target)
	else
		to_chat(owner, span_warning("You have broken concentration with [target] while implanting your hypnosis!"))

/datum/discipline_power/dominate/mesmerize/proc/start_mesmerization_cycle(mob/living/target)
	var/interval_minutes = max(1, 5 - successes_rolled)
	var/interval_deciseconds = interval_minutes * 60 * 10

	// Start with pulse count 1
	addtimer(CALLBACK(src, PROC_REF(mesmerization_pulse), target, interval_deciseconds, 1), interval_deciseconds)

/datum/discipline_power/dominate/mesmerize/proc/mesmerization_pulse(mob/living/target, interval, pulse_count)
	if(!target || target.stat == DEAD)
		// Clean up trait if target is gone
		if(target)
			REMOVE_TRAIT(target, TRAIT_MESMERIZED, TRAIT_GENERIC)
		cleanup_mesmerization()
		return

	// Send the custom hypnotic message in large purple text
	to_chat(target, span_hypnophrase("<font size='4'><b>[custom_message]</b></font>"))

	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg', volume = 30))

	// Check if we've reached 5 pulses
	if(pulse_count >= 5)
		// Remove mesmerize trait - mesmerization fades
		REMOVE_TRAIT(target, TRAIT_MESMERIZED, TRAIT_GENERIC)
		to_chat(target, span_notice("The hypnotic suggestion's pulsing fades, either taking root, or fading silently as your concious slowly returns to its natural state."))
		cleanup_mesmerization()
		return // End the cycle

	// Schedule the next pulse with incremented counter
	addtimer(CALLBACK(src, PROC_REF(mesmerization_pulse), target, interval, pulse_count + 1), interval)

/datum/discipline_power/dominate/mesmerize/proc/force_end_mesmerization()
	if(!current_target)
		return

	// Call mesmerization_pulse with pulse count 6 to end it
	mesmerization_pulse(current_target, 0, 6)

	// Clean up
	cleanup_mesmerization()

/datum/discipline_power/dominate/mesmerize/proc/cleanup_mesmerization()
	current_target = null
	if(end_action)
		end_action.Remove(owner)
		end_action = null

// Action definition - moved outside of the proc
/datum/action/vampire/end_mesmerization
	name = "End Mesmerization"
	desc = "Forcibly end your active mesmerization effect."
	//icon_icon = 'icons/mob/actions/actions_vampire.dmi'
	button_icon_state = "dominate"
	var/datum/discipline_power/dominate/mesmerize/linked_power

/datum/action/vampire/end_mesmerization/New(Target, datum/discipline_power/dominate/mesmerize/power)
	..()
	linked_power = power

/datum/action/vampire/end_mesmerization/Trigger(trigger_flags)
	if(!linked_power)
		Remove(owner)
		return

	linked_power.force_end_mesmerization()

//THE FORGETFUL MIND
/datum/discipline_power/dominate/the_forgetful_mind
	name = "The Forgetful Mind"
	desc = "Invade a person's mind and recreate their memories."

	level = 3

	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_LIVING

	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	duration_length = 3 SECONDS
	range = 7
	var/custom_memory = ""

/datum/discipline_power/dominate/the_forgetful_mind/pre_activation_checks(mob/living/target)

	if(!dominate_hearing_check(owner, target))
		return FALSE
	/*
	target.anchored = TRUE
	owner.anchored = TRUE
	to_chat(list(owner,target), span_info("The Forgetful Mind involves both targets being placed in an intensely hypnotic verbal question-and-answer style probing to discover the target's memories. The target is mind controlled - they cannot lie. The dominator may input their alteration, or removal, when ready."))
	*/
	// Get custom memory alteration from the user
	custom_memory = tgui_input_text(owner, "Memory Alteration", "What memory will you implant or alter?", encode = FALSE)

	if (!custom_memory)
		return FALSE // No message, no memory alteration

	if (HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	if(can_afford())
		if(dominate_check(owner, target, base_difficulty = 6))
			return TRUE
		else
			to_chat(owner, span_warning("[target] has resisted your domination!"))
			do_cooldown(cooldown_length)
			return FALSE
	else
		to_chat(owner, span_warning("You do not have enough blood to cast Dominate!"))
		return FALSE

/datum/discipline_power/dominate/the_forgetful_mind/activate(mob/living/target)
	. = ..()
	target.anchored = TRUE
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_INCAPACITATED, TRAIT_GENERIC)
	if(do_mob(owner, target, 5 SECONDS))
		REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
		REMOVE_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
		target.anchored = FALSE
		to_chat(owner, span_warning("You've successfully invaded [target]'s mind and altered their memories!"))
		owner.say(custom_memory)
		to_chat(target, span_hypnophrase(custom_memory))
		target.add_movespeed_modifier(/datum/movespeed_modifier/dominate)
		SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
		SEND_SIGNAL(target, COMSIG_ALL_MASQUERADE_REINFORCE)

		var/last_margin = mypower - theirpower
		switch(last_margin)
			if(1)
				to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] success. A single memory is removed - and in its place is a void, as if you passed out. Echoes of the true memory may bubble up from time to time..."))
			if(2)
				to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] successes. The words of [owner] are quickly forgotten as they permanently remove entire parts of your memory - never to return."))
			if(3)
				to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] successes. [owner] reaches into your mind without your knowing, altering your memories slightly and perhaps even removing them permanently."))
			if(4)
				to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] successes. [owner] reaches deep into your mind, able to not only remove memory permanently, but re-writing entire conversations or events."))
			if(5)
				to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] successes. Your willpower collapses as [owner] reaches deep into your mind, reconstructing, altering, or perhaps even permanently removing entire periods of your life."))
			else
				to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] successes. Your memory state is totally at the mercy of [owner] as your willpower completely collapses."))
	else
		to_chat(owner, span_danger("Youve broken concentration with [target] and your Domination fails..."))


//CONDITIONING
/datum/discipline_power/dominate/conditioning
	name = "Conditioning"
	desc = "Break a person's mind over time and bend them to your will."

	level = 4

	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_LIVING

	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	duration_length = 6 SECONDS
	range = 2

/datum/discipline_power/dominate/conditioning/pre_activation_checks(mob/living/target)

	if(!dominate_hearing_check(owner, target))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	domination_succeeded = dominate_check(owner, target, base_difficulty = 6)
	if(domination_succeeded)
		return TRUE
	else
		do_cooldown(cooldown_length)
		return FALSE


/datum/discipline_power/dominate/conditioning/activate(mob/living/target)
	. = ..()

	if(domination_succeeded)
		target.dir = get_dir(target, owner)
		to_chat(target, span_danger("LOOK AT ME"))
		owner.say("Look at me.")
		target.anchored = TRUE
		if(do_mob(owner, target, 20 SECONDS))
			target.anchored = FALSE
			target.conditioned = TRUE
			target.conditioner = WEAKREF(owner)
			target.additional_social -= 3
			to_chat(target, span_hypnophrase("Your mind is filled with thoughts surrounding [owner]. Their every word and gesture carries weight to you."))
			SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
	else
		to_chat(owner, span_warning("[target]'s mind has resisted your domination!"))

/datum/discipline_power/dominate/conditioning/deactivate(mob/living/target)
	. = ..()

//POSSESSION
/datum/discipline_power/dominate/possession
	name = "Possession"
	desc = "Take full control of your target's mind and body."

	level = 5

	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_HUMAN

	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	range = 7


/datum/discipline_power/dominate/possession/pre_activation_checks(mob/living/target)

	if(!dominate_hearing_check(owner, target))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	domination_succeeded = dominate_check(owner, target, base_difficulty = 7)
	if(domination_succeeded)
		return TRUE
	else
		do_cooldown(cooldown_length)
		return FALSE

/datum/discipline_power/dominate/possession/activate(mob/living/carbon/human/target)
	. = ..()

	if(domination_succeeded)
		to_chat(owner, span_warning("You've successfully dominated [target]'s mind!"))
		to_chat(target, span_danger("HIT YOURSELF"))
		owner.say("Hit yourself.")

		var/datum/cb = CALLBACK(target, /mob/living/carbon/human/proc/attack_myself_command)
		for(var/i in 1 to 20)
			addtimer(cb, (i - 1) * 1.5 SECONDS)
		SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
	else
		to_chat(owner, span_warning("[target]'s mind has resisted your domination!"))


/mob/living/carbon/human/proc/attack_myself_command()
	if(!CheckFrenzyMove())
		set_combat_mode(TRUE)
		var/obj/item/I = get_active_held_item()
		if(I)
			if(I.force)
				ClickOn(src)
			else
				drop_all_held_items()
				ClickOn(src)
		else
			ClickOn(src)

/mob/living/carbon/human/proc/post_dominate_checks(mob/living/carbon/human/dominate_target)
	if(dominate_target)
		dominate_target.remove_overlay(MUTATIONS_LAYER)

//AUTONOMIC MASTERY
/datum/discipline_power/dominate/autonomic_mastery
	name = "Autonomic Mastery"
	desc = "Control the Autonomic Systems of a target."

	level = 6

	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_HUMAN

	cooldown_length = 15 SECONDS
	range = 7

/datum/discipline_power/dominate/autonomic_mastery/pre_activation_checks(mob/living/target)

	if(!dominate_hearing_check(owner, target))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	domination_succeeded = dominate_check(owner, target, base_difficulty = 5)
	if(domination_succeeded)
		return TRUE
	else
		do_cooldown(cooldown_length)
		return FALSE

/datum/discipline_power/dominate/autonomic_mastery/activate(mob/living/carbon/human/target)
	. = ..()
	if(domination_succeeded)
		to_chat(owner, span_warning("You've successfully dominated [target]'s bodily functions!"))
		var/list/orders = list("Sleep", "Wake", "Heart Attack", "Revive")
		var/order = tgui_input_list(owner, "Select a Command","Command Selection", orders)
		if(!order)
			return
		switch(order)
			if("Sleep")
				owner.say("Sleep")
				target.Sleeping(200)
				to_chat(target, span_danger("You feel suddenly exhausted"))
				SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
			if("Wake")
				owner.say("Wake")
				target.SetSleeping(0)
				to_chat(target, span_danger("You feel suddenly energetic"))
				SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
			if("Heart Attack")
				owner.say("Die")
				target.adjustStaminaLoss(60, FALSE)
				target.set_heartattack(TRUE)
				to_chat(target, span_danger("You feel a terrible pain in your chest!"))
				SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
			if("Revive")
				owner.say("Live")
				target.set_heartattack(FALSE)
				to_chat(target, span_danger("You feel your heart pound!"))
				target.revive(full_heal = FALSE, admin_revive = FALSE)
				SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
	else
		to_chat(owner, span_warning("[target]'s mind has resisted your domination!"))

