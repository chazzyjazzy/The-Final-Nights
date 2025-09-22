
#define TRAIT_MESMERIZED "mesmerized"
#define TRAIT_DOMINATE_IMMUNE "dominate_immune"

/datum/discipline/dominate
	name = "Dominate"
	desc = "Suppresses will of your targets and forces them to obey you, if their will is not more powerful than yours."
	icon_state = "dominate"
	power_type = /datum/discipline_power/dominate

/datum/discipline/dominate/post_gain()
	. = ..()
	if(level >= 5)
		//var/obj/effect/proc_holder/spell/voice_of_god/voice_of_domination = new(owner)
		//owner.mind.AddSpell(voice_of_domination)
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
	if(!ishuman(target))
		return TRUE

	var/mob/living/carbon/human/dominate_target = target
	dominate_target.remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/dominate_overlay = mutable_appearance('code/modules/wod13/icons.dmi', "dominate", -MUTATIONS_LAYER)
	dominate_overlay.pixel_z = 2
	dominate_target.overlays_standing[MUTATIONS_LAYER] = dominate_overlay
	dominate_target.apply_overlay(MUTATIONS_LAYER)
	dominate_target.face_atom(owner)
	to_chat(dominate_target, span_danger("You find yourself completely entranced by the stare of [owner]. You can't bring yourself to look away, call for help, or even attempt resistance. Pray that someone comes to save you by dragging or pushing you away."))
	owner.face_atom(dominate_target)
	to_chat(dominate_target, span_info("If someone is using Dominate to compel you to do something you are personally uncomfortable with as a player, you are allowed to ignore it. Follow the spirit of the dominate - not just the letter!"))
	addtimer(CALLBACK(dominate_target, TYPE_PROC_REF(/mob/living/carbon/human, post_dominate_checks), dominate_target), 2 SECONDS)
	return TRUE

/datum/discipline_power/dominate/proc/dominate_hearing_check(mob/living/carbon/human/owner, mob/living/target)
	var/list/hearers = get_hearers_in_view(8, owner)
	if(!(target in hearers))
		to_chat(owner, span_warning("[target] cannot hear you — they are too far or behind an obstruction."))
		return FALSE
	to_chat(owner, span_info("[target] hears you clearly."))
	return TRUE

/datum/discipline_power/dominate/proc/dominate_check(mob/living/carbon/human/owner, mob/living/target, tiebreaker = FALSE, base_difficulty = 4)
	if(!ishuman(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_DOMINATE_IMMUNE))
		to_chat(owner, span_warning("A Dominate attempt has botched against this person and they may no longer be Dominated for the rest of the night."))
		return FALSE

	// ATTENTION : This rolling system is not lore accurate. According to Vampire v20, all Dominate powers are rolled the attacker's stats using the defenders current willpower points as a difficulty.
	// This system serves a placeholder until satisfactory mechanics can be made for willpower. If we did not have this system, the max difficulty for all dominate attempts would be 5 (target.get_total_mentality())
	mypower = SSroll.storyteller_roll(owner.get_total_social(), difficulty = base_difficulty, mobs_to_show_output = owner, numerical = TRUE)
	theirpower = SSroll.storyteller_roll(target.get_total_mentality(), difficulty = 6, mobs_to_show_output = target, numerical = TRUE)

	var/mob/living/carbon/human/conditioner = target.conditioner?.resolve()
	if(owner == conditioner)
		return TRUE

	var/mob/living/carbon/human/human_target = target
	if(human_target.clan?.name == CLAN_GARGOYLE)
		theirpower -= 2
	if(target.conditioned)
		theirpower += 3

	if(mypower < 0)
		ADD_TRAIT(target, TRAIT_DOMINATE_IMMUNE, TRAIT_GENERIC)
		to_chat(owner, span_warning("A Dominate attempt has botched against this person and they may no longer be Dominated for the rest of the night."))
		return FALSE

	return (mypower > theirpower && owner.generation <= target.generation)

/datum/discipline_power/dominate/proc/immobilize_target(mob/living/target, duration = 5 SECONDS)
	target.anchored = TRUE
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
	if(do_mob(owner, target, duration))
		release_target(target)
		return TRUE
	release_target(target)
	return FALSE

/datum/discipline_power/dominate/proc/release_target(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	REMOVE_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
	target.anchored = FALSE

/datum/discipline_power/dominate/proc/get_success_message(margin, target_name)
	switch(margin)
		if(1)
			return "mild vigor and short duration"
		if(2)
			return "normal compulsion"
		if(3)
			return "moderate vigor and extended duration"
		if(4)
			return "great vigor and long duration"
		if(5)
			return "supernatural vigor"
		else
			return "immediate and vigorous completion"

/datum/movespeed_modifier/dominate
	multiplicative_slowdown = 5

// COMMAND
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

/datum/discipline_power/dominate/command/pre_activation_checks(mob/living/target)
	if(!dominate_hearing_check(owner, target))
		return FALSE

	to_chat(owner, span_info("Dominate 'Commands' may be only one word."))
	custom_command = tgui_input_text(owner, "Dominate Command", "What is your command?", encode = FALSE)

	if(!custom_command || !can_afford())
		if(!can_afford())
			to_chat(owner, span_warning("You do not have enough blood to cast Dominate!"))
		return FALSE

	if(length(splittext(custom_command, " ")) > 1)
		to_chat(owner, span_warning("Commands must be only ONE word!"))
		return FALSE

	// in place of manipulation + intimidation with the difficulty being the victims current willpower
	if(dominate_check(owner, target, base_difficulty = 4))
		return TRUE

	to_chat(owner, span_warning("[target] has resisted your domination!"))
	do_cooldown(TRUE)
	return FALSE

/datum/discipline_power/dominate/command/activate(mob/living/target)
	. = ..()
	to_chat(owner, span_warning("You've successfully dominated [target]'s mind!"))
	owner.say(custom_command)
	to_chat(target, span_big("[custom_command]"))
	var/last_margin = mypower - theirpower
	var/vigor_text = get_success_message(last_margin, target.name)
	to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] successes. You feel compelled to [custom_command] with [vigor_text]."))
	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))

// MESMERIZE
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
	var/pulse_active = FALSE

/datum/discipline_power/dominate/mesmerize/pre_activation_checks(mob/living/target)
	if(!dominate_hearing_check(owner, target) || HAS_TRAIT(target, TRAIT_MESMERIZED))
		if(HAS_TRAIT(target, TRAIT_MESMERIZED))
			to_chat(owner, span_warning("[target] is already under a hypnotic suggestion!"))
		return FALSE

	custom_message = tgui_input_text(owner, "Hypnotic Suggestion", "What hypnotic message will echo in their mind?", encode = FALSE)
	if(!custom_message)
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		dominate_succeeded = TRUE
		successes_rolled = 5
		return TRUE

	// in place of manipulation + leadership with the difficulty being the victims current willpower

	var/domination_result = dominate_check(owner, target, base_difficulty = 5)
	if(domination_result > 0)
		dominate_succeeded = TRUE
		successes_rolled = domination_result
		return TRUE

	dominate_succeeded = FALSE
	successes_rolled = 0
	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/dominate/mesmerize/activate(mob/living/target)
	. = ..()
	if(!immobilize_target(target, 10 SECONDS))
		to_chat(owner, span_warning("You have broken concentration with [target] while implanting your hypnosis!"))
		return

	to_chat(owner, span_warning("You've successfully planted a hypnotic suggestion in [target]'s mind!"))
	to_chat(target, span_info("An urging, subconcious thought has entered your mind. Youre not sure how this happened - but it keeps pulsing, forcing your conscious thought to bend toward it."))
	owner.say(custom_message)
	to_chat(target, span_hypnophrase(custom_message))
	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))

	current_target = target
	ADD_TRAIT(target, TRAIT_MESMERIZED, TRAIT_GENERIC)
	end_action = new(owner, src)
	end_action.Grant(owner)
	pulse_active = TRUE
	start_mesmerization_cycle(target)

/datum/discipline_power/dominate/mesmerize/proc/start_mesmerization_cycle(mob/living/target)
	if(!pulse_active)
		return
	var/interval_minutes = max(1, 5 - successes_rolled)
	var/interval_deciseconds = interval_minutes * 60 * 10
	addtimer(CALLBACK(src, PROC_REF(mesmerization_pulse), target, interval_deciseconds, 1), interval_deciseconds)

/datum/discipline_power/dominate/mesmerize/proc/mesmerization_pulse(mob/living/target, interval, pulse_count)
	if(!pulse_active || !target || target.stat == DEAD)
		if(target)
			REMOVE_TRAIT(target, TRAIT_MESMERIZED, TRAIT_GENERIC)
		cleanup_mesmerization()
		return

	to_chat(target, span_hypnophrase("<font size='4'><b>[custom_message]</b></font>"))
	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg', volume = 30))

	if(pulse_count >= 5)
		REMOVE_TRAIT(target, TRAIT_MESMERIZED, TRAIT_GENERIC)
		to_chat(target, span_notice("The hypnotic suggestion's pulsing fades, either taking root, or fading silently as your concious slowly returns to its natural state."))
		cleanup_mesmerization()
		return

	if(pulse_active)
		addtimer(CALLBACK(src, PROC_REF(mesmerization_pulse), target, interval, pulse_count + 1), interval)

/datum/discipline_power/dominate/mesmerize/proc/force_end_mesmerization()
	if(!current_target || !pulse_active)
		return
	pulse_active = FALSE
	REMOVE_TRAIT(current_target, TRAIT_MESMERIZED, TRAIT_GENERIC)
	to_chat(current_target, span_notice("The hypnotic suggestion's pulsing fades, either taking root, or fading silently as your concious slowly returns to its natural state."))
	cleanup_mesmerization()

/datum/discipline_power/dominate/mesmerize/proc/cleanup_mesmerization()
	pulse_active = FALSE
	current_target = null
	if(end_action)
		end_action.Remove(owner)
		end_action = null

/datum/action/vampire/end_mesmerization
	name = "End Mesmerization"
	desc = "Forcibly end your active mesmerization effect."
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

// THE FORGETFUL MIND
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

	custom_memory = tgui_input_text(owner, "Memory Alteration", "What memory will you implant or alter?", encode = FALSE)
	if(!custom_memory)
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	if(!can_afford())
		to_chat(owner, span_warning("You do not have enough blood to cast Dominate!"))
		return FALSE

	// in place of wits + subterfuge with the difficulty being the victims current willpower
	if(dominate_check(owner, target, base_difficulty = 6))
		return TRUE

	to_chat(owner, span_warning("[target] has resisted your domination!"))
	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/dominate/the_forgetful_mind/activate(mob/living/target)
	. = ..()
	if(!immobilize_target(target, 10 SECONDS))
		to_chat(owner, span_danger("Youve broken concentration with [target] and your Domination fails..."))
		return

	to_chat(owner, span_warning("You've successfully invaded [target]'s mind and altered their memories!"))
	owner.say(custom_memory)
	to_chat(target, span_hypnophrase(custom_memory))
	//target.add_movespeed_modifier(/datum/movespeed_modifier/dominate)
	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))
	SEND_SIGNAL(target, COMSIG_ALL_MASQUERADE_REINFORCE)

	var/last_margin = mypower - theirpower
	var/list/memory_messages = list(
		"A single memory is removed - and in its place is a void, as if you passed out. Echoes of the true memory may bubble up from time to time...",
		"The words of [owner] are quickly forgotten as they permanently remove entire parts of your memory - never to return.",
		"[owner] reaches into your mind without your knowing, altering your memories slightly and perhaps even removing them permanently.",
		"[owner] reaches deep into your mind, able to not only remove memory permanently, but re-writing entire conversations or events.",
		"Your willpower collapses as [owner] reaches deep into your mind, reconstructing, altering, or perhaps even permanently removing entire periods of your life.",
		"Your memory state is totally at the mercy of [owner] as your willpower completely collapses."
	)
	var/message_index = clamp(last_margin, 1, 6)
	to_chat(target, span_warning("[owner] has successfully dominated your mind with [last_margin] success[last_margin == 1 ? "" : "es"]. [memory_messages[message_index]]"))

// CONDITIONING
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

	if(HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	// in place of charisma + leadership with the difficulty being the victims current willpower
	domination_succeeded = dominate_check(owner, target, base_difficulty = 6)
	if(!domination_succeeded)
		do_cooldown(cooldown_length)
	return domination_succeeded

/datum/discipline_power/dominate/conditioning/activate(mob/living/target)
	. = ..()
	if(!domination_succeeded)
		if(!immobilize_target(target, 1 SECONDS))
			return
		to_chat(owner, span_warning("[target]'s mind has resisted your domination!"))
		return

	target.anchored = TRUE
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESTRAINED, TRAIT_GENERIC)
	target.dir = get_dir(target, owner)
	to_chat(target, span_danger("LOOK AT ME"))
	owner.say("Look at me.")

	if(do_mob(owner, target, 20 SECONDS))
		target.conditioned = TRUE
		target.conditioner = WEAKREF(owner)
		target.additional_social -= 3
		to_chat(target, span_hypnophrase("Your mind is filled with thoughts surrounding [owner]. Their every word and gesture carries immense weight to you."))
		SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))

	release_target(target)

// POSSESSION (Condensed but maintaining all functionality)
/datum/discipline_power/dominate/possession
	name = "Possession"
	desc = "Take full control of your target's mind and body."
	level = 5
	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK|DISC_CHECK_SEE
	target_type = TARGET_HUMAN
	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	range = 7
	var/datum/possession_controller/active_possession

/datum/discipline_power/dominate/possession/pre_activation_checks(mob/living/target)
	if(!dominate_hearing_check(owner, target))
		return FALSE

	if(iskindred(target) || isgarou(target))
		to_chat(owner, span_warning("You cannot possess [iskindred(target) ? "another kindred" : "a garou - the beast within resists"]!"))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	if(!can_afford())
		to_chat(owner, span_warning("You do not have enough blood to cast Dominate!"))
		return FALSE

	// in place of charisma + intimidation with the difficulty being the victims current willpower
	domination_succeeded = dominate_check(owner, target, base_difficulty = 7)
	if(!domination_succeeded)
		to_chat(owner, span_warning("[target] has resisted your domination!"))
		do_cooldown(cooldown_length)
	return domination_succeeded

/datum/discipline_power/dominate/possession/activate(mob/living/carbon/human/target)
	. = ..()
	if(!domination_succeeded)
		return

	target.dir = get_dir(target, owner)
	to_chat(target, span_danger("Your body freezes as an overwhelming presence invades your mind..."))
	to_chat(owner, span_warning("You begin weaving your consciousness into [target]'s mind..."))

	if(!immobilize_target(target, 20 SECONDS))
		to_chat(owner, span_warning("Your concentration was broken! The possession preparation failed."))
		to_chat(target, span_notice("The oppressive mental presence suddenly withdraws."))
		return

	var/datum/action/possession_trigger/trigger_action = new(target, src)
	trigger_action.Grant(owner)
	to_chat(owner, span_warning("You have prepared [target]'s mind for possession. You may now take control at will."))
	to_chat(target, span_danger("Your mind feels vulnerable and exposed. Something terrible is about to happen..."))
	SEND_SOUND(target, sound('code/modules/wod13/sounds/dominate.ogg'))

// AUTONOMIC MASTERY
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

	if(HAS_TRAIT(target, TRAIT_CANNOT_RESIST_MIND_CONTROL))
		return TRUE

	domination_succeeded = dominate_check(owner, target, base_difficulty = 5)
	if(!domination_succeeded)
		do_cooldown(cooldown_length)
	return domination_succeeded

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
		to_chat(target, span_warning("Your thoughts blur—[owner] tries to bend your will. You resist."))

// Possession system (keeping existing complex logic but organized)
/datum/action/possession_trigger
	name = "Possess Target"
	desc = "Take control of the prepared target's body."
	button_icon_state = "possession_start"
	check_flags = NONE
	var/mob/living/carbon/human/prepared_target
	var/datum/discipline_power/dominate/possession/source_power

/datum/action/possession_trigger/New(mob/living/carbon/human/target, datum/discipline_power/dominate/possession/power)
	prepared_target = target
	source_power = power
	..()

/datum/action/possession_trigger/Trigger(trigger_flags)
	if(!prepared_target || !source_power || QDELETED(prepared_target) || prepared_target.stat == DEAD)
		if(!QDELETED(prepared_target) && prepared_target.stat == DEAD)
			to_chat(owner, span_warning("Your prepared target is no longer viable for possession."))
		Remove(owner)
		qdel(src)
		return

	source_power.active_possession = new /datum/possession_controller(owner, prepared_target, source_power)
	Remove(owner)
	qdel(src)
	return TRUE

// Keep existing possession controller and observer code as is since it's complex and working
/datum/possession_controller
	var/mob/living/carbon/human/vampire_original
	var/mob/living/carbon/human/mortal_body
	var/mob/living/possession_observer/mortal_observer
	var/datum/discipline_power/dominate/possession/source_power
	var/possession_active = FALSE

/datum/possession_controller/New(mob/living/carbon/human/vampire, mob/living/carbon/human/mortal, datum/discipline_power/dominate/possession/power)
	vampire_original = vampire
	mortal_body = mortal
	source_power = power
	start_possession()

/datum/possession_controller/proc/start_possession()
	if(QDELETED(vampire_original) || QDELETED(mortal_body))
		qdel(src)
		return

	mortal_observer = new(mortal_body, src)
	mortal_observer.ckey = mortal_body.ckey
	mortal_observer.name = mortal_body.real_name
	mortal_observer.real_name = mortal_body.real_name
	if(mortal_body.mind)
		mortal_observer.mind = mortal_body.mind

	mortal_body.ckey = vampire_original.ckey
	if(vampire_original.mind)
		mortal_body.mind = vampire_original.mind

	var/datum/action/possession/end_possession/end_action = new(src)
	end_action.Grant(mortal_body)
	vampire_original.SetUnconscious(999999)
	vampire_original.visible_message(span_warning("[vampire_original]'s eyes roll back and they collapse into a catatonic state!"))
	possession_active = TRUE

/datum/possession_controller/proc/end_possession(forced = FALSE)
	if(!possession_active || QDELETED(vampire_original) || QDELETED(mortal_body))
		cleanup()
		return

	if(mortal_body.stat == DEAD)
		handle_death_during_possession()
		return

	if(!forced)
		to_chat(vampire_original, span_warning("You withdraw from [mortal_body.real_name]'s mind and return to your own body."))

	vampire_original.ckey = mortal_body.ckey
	if(mortal_body.mind)
		vampire_original.mind = mortal_body.mind
	vampire_original.SetUnconscious(0)

	if(mortal_observer?.ckey)
		mortal_body.ckey = mortal_observer.ckey
		if(mortal_observer.mind)
			mortal_body.mind = mortal_observer.mind
		to_chat(mortal_body, span_notice("Your consciousness returns to your own body as the foreign presence withdraws."))

	cleanup()

/datum/possession_controller/proc/handle_death_during_possession()
	to_chat(vampire_original, span_boldwarning("The death of your host body violently ejects you from their mind!"))
	vampire_original.ckey = mortal_body.ckey
	if(mortal_body.mind)
		vampire_original.mind = mortal_body.mind

	vampire_original.SetUnconscious(999999)
	vampire_original.adjustBruteLoss(50)
	vampire_original.visible_message(span_danger("[vampire_original] suddenly convulses violently and falls into what appears to be a coma!"))
	to_chat(vampire_original, span_boldwarning("The psychic shock of your host's death sends you into torpor!"))

	if(mortal_observer)
		to_chat(mortal_observer, span_boldwarning("Your body has died while you were displaced from it. You fade into oblivion..."))
		mortal_observer.ghostize()

	cleanup()

/datum/possession_controller/proc/cleanup()
	possession_active = FALSE
	for(var/datum/action/possession/action in vampire_original.actions + mortal_body.actions)
		action.Remove(action.owner)
		qdel(action)
	if(mortal_observer)
		qdel(mortal_observer)
		mortal_observer = null
	if(source_power)
		source_power.active_possession = null
	qdel(src)

/mob/living/possession_observer
	name = "displaced consciousness"
	real_name = "displaced consciousness"
	var/mob/living/carbon/possessed_body
	var/datum/possession_controller/controller

/mob/living/possession_observer/Initialize(mapload, datum/possession_controller/_controller)
	if(iscarbon(loc))
		possessed_body = loc
		controller = _controller
	return ..()

/mob/living/possession_observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_warning("Your consciousness has been displaced from your body by a supernatural force. You can only observe as another mind controls your physical form."))
	to_chat(src, span_notice("You are helpless to act, but can still observe and think. Pray that the intruder releases control soon..."))

/mob/living/possession_observer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, span_warning("You have no voice while displaced from your body!"))
	return FALSE

/mob/living/possession_observer/emote(act, m_type = null, message = null, intentional = FALSE)
	to_chat(src, span_warning("You cannot express yourself while displaced from your body!"))
	return FALSE

/datum/action/possession
	var/datum/possession_controller/controller

/datum/action/possession/New(datum/possession_controller/_controller)
	controller = _controller
	..()

/datum/action/possession/end_possession
	name = "End Possession"
	desc = "Release control of the possessed body and return to your own."
	button_icon_state = "possession_end"
	check_flags = NONE

/datum/action/possession/end_possession/Trigger(trigger_flags)
	if(!controller)
		Remove(owner)
		qdel(src)
		return
	controller.end_possession()
	return TRUE

/mob/living/carbon/human/proc/attack_myself_command()
	if(!CheckFrenzyMove())
		set_combat_mode(TRUE)
		var/obj/item/I = get_active_held_item()
		if(I?.force)
			ClickOn(src)
		else
			if(I)
				drop_all_held_items()
			ClickOn(src)

/mob/living/carbon/human/proc/post_dominate_checks(mob/living/carbon/human/dominate_target)
	dominate_target?.remove_overlay(MUTATIONS_LAYER)

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
