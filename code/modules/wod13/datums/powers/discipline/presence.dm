#define TRAIT_PRESENCE_IMMUNE "presence_immune"

/datum/discipline/presence
	name = "Presence"
	desc = "Allows you to attract, sway, and control crowds through supernatural allure and emotional manipulation."
	icon_state = "presence"
	power_type = /datum/discipline_power/presence

/datum/discipline/presence/post_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_CHARMER, /datum/discipline/presence)

/datum/discipline_power/presence
	name = "Presence power name"
	desc = "Presence power description"
	activate_sound = 'code/modules/wod13/sounds/presence_activate.ogg'
	deactivate_sound = 'code/modules/wod13/sounds/presence_deactivate.ogg'

/datum/discipline_power/presence/proc/presence_hearing_check(mob/living/carbon/human/owner, mob/living/target)
	var/list/hearers = get_hearers_in_view(8, owner)
	if(!(target in hearers))
		to_chat(owner, span_warning("[target] cannot hear you — they are too far or behind an obstruction."))
		return FALSE
	to_chat(owner, span_info("[target] hears you clearly."))
	return TRUE

/datum/discipline_power/presence/proc/presence_check(mob/living/carbon/human/owner, mob/living/target, difficulty)
	if(!ishuman(target))
		return 0

	if(HAS_TRAIT(target, TRAIT_PRESENCE_IMMUNE))
		to_chat(owner, span_warning("A presence attempt has botched against this person and they may no longer have Presence used on them for the rest of the night."))
		return 0

	var/theirpower = difficulty || target.get_total_mentality()

	var/successes = SSroll.storyteller_roll(owner.get_total_social(), difficulty = theirpower, mobs_to_show_output = owner, numerical = TRUE)

	if((owner.generation - 3) >= target.generation)
		return 0

	if(successes < 0)
		ADD_TRAIT(target, TRAIT_PRESENCE_IMMUNE, TRAIT_GENERIC)
		to_chat(owner, span_warning("A presence attempt has botched against this person and they may no longer have Presence used on them for the rest of the night."))
		return 0

	return successes

/datum/discipline_power/presence/proc/apply_presence_overlay(mob/living/carbon/target)
	target.remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/presence_overlay = mutable_appearance('code/modules/wod13/icons.dmi', "presence", -MUTATIONS_LAYER)
	presence_overlay.pixel_z = 1
	target.overlays_standing[MUTATIONS_LAYER] = presence_overlay
	target.apply_overlay(MUTATIONS_LAYER)
	SEND_SOUND(target, sound('code/modules/wod13/sounds/presence_activate.ogg'))

/datum/discipline_power/presence/proc/sort_targets_by_mentality(list/targets)
	var/list/sorted = list()
	for(var/mob/living/carbon/target in targets)
		var/target_mentality = target.get_total_mentality()
		var/inserted = FALSE

		for(var/i = 1; i <= length(sorted); i++)
			var/mob/living/carbon/existing = sorted[i]
			if(target_mentality < existing.get_total_mentality())
				sorted.Insert(i, target)
				inserted = TRUE
				break

		if(!inserted)
			sorted += target
	return sorted

/atom/movable/screen/alert/entrancement
	name = "Entranced"
	desc = "You are completely entranced and compelled to serve."
	icon_state = "hypnosis"

// AWE
/datum/discipline_power/presence/awe
	name = "Awe"
	desc = "Make those around you admire and want to be closer to you."
	level = 1
	vitae_cost = 1
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_SPEAK
	range = 7
	multi_activate = FALSE
	cooldown_length = 15 SECONDS
	duration_length = 5 SECONDS
	vitae_cost = 1
	var/successes = 0
	var/list/affected_targets = list()

/datum/discipline_power/presence/awe/pre_activation_checks()
	.=..()

	//in place of charisma + performance
	successes = SSroll.storyteller_roll(owner.get_total_social(), difficulty = 7, mobs_to_show_output = owner, numerical = TRUE)
	if(successes > 0)
		return TRUE

	to_chat(owner, span_warning("Your presence fails to captivate anyone around you."))
	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/presence/awe/activate()
	. = ..()

	var/list/potential_targets = list()
	for(var/mob/living/carbon/target in hearers(range, owner))
		if(target != owner)
			potential_targets += target

	if(!length(potential_targets))
		to_chat(owner, span_warning("There is no one around to be awed by your presence."))
		return

	var/list/target_counts = list(1, 2, 6, 20, length(potential_targets))
	var/targets_to_affect = target_counts[clamp(successes, 1, 5)]

	potential_targets = sort_targets_by_mentality(potential_targets)
	affected_targets = list()

	for(var/i = 1; i <= min(targets_to_affect, length(potential_targets)); i++)
		var/mob/living/carbon/target = potential_targets[i]
		apply_presence_overlay(target)
		to_chat(target, span_yellowteamradio("You feel extremely attracted to and persuaded by [owner]'s words, no matter what they're saying!"))
		affected_targets += target

	var/affected_count = length(affected_targets)
	if(affected_count > 0)
		to_chat(owner, span_warning("Your commanding presence captivates [affected_count] [affected_count == 1 ? "person" : "people"] around you!"))
	else
		to_chat(owner, span_warning("Your presence fails to affect anyone around you."))

/datum/discipline_power/presence/awe/deactivate()
	. = ..()
	for(var/mob/living/carbon/target in affected_targets)
		target.remove_overlay(MUTATIONS_LAYER)
	affected_targets.Cut()

// DREAD GAZE
/datum/discipline_power/presence/dread_gaze
	name = "Dread Gaze"
	desc = "Incite fear in others through only your words and gaze."
	level = 2
	vitae_cost = 1
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_SPEAK
	target_type = TARGET_HUMAN
	range = 7
	multi_activate = TRUE
	cooldown_length = 15 SECONDS
	duration_length = 5 SECONDS
	vitae_cost = 1 //no mention of literally any cost for using this
	var/successes = 0


/datum/discipline_power/presence/dread_gaze/pre_activation_checks(mob/living/target)
	if(!presence_hearing_check(owner, target))
		return FALSE

	//in place of charisma + intimidation, difficulty equal to the victims wits + courage
	successes = presence_check(owner, target)
	if(successes > 0)
		return TRUE

	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/presence/dread_gaze/activate(mob/living/carbon/human/target)
	. = ..()
	apply_presence_overlay(target)

	if(successes <= 3)
		to_chat(target, span_userdanger("You are consumed with terror toward [owner]!"))
		to_chat(owner, span_warning("You've struck terror into [target]'s heart with your dreadful gaze!"))
	else
		to_chat(target, span_userdanger("Overwhelming dread fills you! You must get away from [owner]!"))
		to_chat(owner, span_warning("Your terrifying presence sends [target] fleeing in terror!"))

		var/datum/cb = CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon/human, step_away_caster), owner)
		for(var/i in 1 to 30)
			addtimer(cb, (i - 1) * target.total_multiplicative_slowdown())

/datum/discipline_power/presence/dread_gaze/deactivate(mob/living/carbon/human/target)
	. = ..()
	target.remove_overlay(MUTATIONS_LAYER)

// ENTRANCEMENT
/datum/discipline_power/presence/entrancement
	name = "Entrancement"
	desc = "Manipulate minds by bending emotions to your will."
	level = 3
	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK
	target_type = TARGET_HUMAN
	range = 7
	multi_activate = TRUE
	cooldown_length = 3 MINUTES
	duration_length = 5 SECONDS
	vitae_cost = 1
	var/successes = 0

/datum/discipline_power/presence/entrancement/pre_activation_checks(mob/living/target)
	if(!presence_hearing_check(owner, target))
		return FALSE

	//in place of appearance + empathy
	successes = presence_check(owner, target)
	if(successes > 0)
		return TRUE

	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/presence/entrancement/activate(mob/living/carbon/human/target)
	. = ..()
	if(!.)
		to_chat(owner, span_warning("[target] doesnt seem entranced by your words."))
		return
	target.throw_alert("entrancement", /atom/movable/screen/alert/entrancement)
	log_combat(owner, target, "Used Presence Entrancement")
	apply_presence_overlay(target)
	to_chat(target, span_hypnophrase("You find yourself becoming completely entraced by [owner]. You are now their willing servant."))
	to_chat(target, span_info("You are now the willing servant of [owner]. You will seek to please them and fulfill their every desire, but this desire will fade soon."))
	addtimer(CALLBACK(src, PROC_REF(end_entrancement), target), successes * 1 INGAME_HOURS)

/datum/discipline_power/presence/entrancement/proc/end_entrancement(mob/living/carbon/human/target)
	to_chat(target, span_hypnophrase("Your desire to fulfill [owner]'s every desire fades."))
	target.clear_alert("entrancement")

/datum/discipline_power/presence/entrancement/deactivate(mob/living/carbon/human/target)
	. = ..()
	target.remove_overlay(MUTATIONS_LAYER)

// SUMMON
/datum/discipline_power/presence/summon
	name = "Summon"
	desc = "Call anyone you've ever met to be by your side."
	level = 4
	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK
	range = 7
	multi_activate = TRUE
	cooldown_length = 20 MINUTES
	duration_length = 5 SECONDS
	vitae_cost = 1
	var/successes = 0
	var/mob/living/carbon/human/summon_target

/datum/discipline_power/presence/summon/pre_activation_checks(mob/living/target)
	var/summon_target_name = tgui_input_text(owner, "Summon Target:", "Summon Target")
	if(!summon_target_name)
		return FALSE

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.real_name == summon_target_name)
			summon_target = H
			break

	if(!summon_target)
		to_chat(owner, span_warning("You cannot sense anyone by that name."))
		return FALSE

	//in place of charisma + subterfuge
	successes = presence_check(owner, summon_target, 7)
	if(successes > 0)
		return TRUE

	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/presence/summon/activate(mob/living/carbon/human/target)
	. = ..()
	if(!. || !summon_target)
		to_chat(owner, span_warning("Your summons failed to reach [summon_target ? summon_target.real_name : "your target"]."))
		return

	apply_presence_overlay(summon_target)

	var/turf/owner_turf = get_turf(owner)
	var/location_info = "[get_area_name(owner_turf)], X:[owner_turf.x] Y:[owner_turf.y] Z:[owner_turf.z]"
	to_chat(summon_target, span_yellowteamradio("[owner] is summoning you to their location. [owner] is currently at [location_info]"))

	var/list/flavor_texts = list(
		"You feel a faint pull towards [owner], approaching slowly and hesitantly.",
		"You feel reluctantly compelled to seek out [owner], though obstacles easily deter you.",
		"You feel a strong urge to go to [owner] with reasonable speed.",
		"You feel compelled to rush to [owner] with haste, overcoming any obstacles in your way, but not endangering yourself.",
		"You feel an overwhelming need to rush to [owner], doing anything to get to them."
	)

	var/flavor_index = clamp(successes, 1, 5)
	to_chat(summon_target, span_yellowteamradio(flavor_texts[flavor_index]))
	to_chat(summon_target, span_info("Summon only affects targets who have reasonably met the summoner. If you believe your character would reasonably have never met the summoner, this power is ineffective."))
	to_chat(owner, span_warning("You've successfully summoned [summon_target.real_name] to your presence! ([successes] success\s)"))
	summon_target.do_jitter_animation(3 SECONDS)

/datum/discipline_power/presence/summon/deactivate(mob/living/carbon/human/target)
	. = ..()
	summon_target?.remove_overlay(MUTATIONS_LAYER)

// MAJESTY
/datum/discipline_power/presence/majesty
	name = "Majesty"
	desc = "Become so grand that others find it nearly impossible to disobey or harm you."
	level = 5
	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK
	range = 7
	multi_activate = TRUE
	cooldown_length = 12 MINUTES
	duration_length = 3 MINUTES
	vitae_cost = 1 //'but she must spend a willpower point' placeholder
	var/list/affected_targets = list()

/datum/discipline_power/presence/majesty/pre_activation_checks(mob/living/target)
	return TRUE

/datum/discipline_power/presence/majesty/activate(mob/living/carbon/human/target)
	. = ..()
	affected_targets = list()
	for(var/mob/living/carbon/human/hearer in get_hearers_in_view(range, owner))
		if(hearer == owner)
			continue

		//'the victim must make a courage roll with a difficulty equal to the caster's charisma + intimidation to a maximum of 10' this is in place of that
		var/hearer_successes = SSroll.storyteller_roll(hearer.get_total_social(), difficulty = owner.get_total_social(), mobs_to_show_output = hearer, numerical = TRUE)
		hearer_successes = max(0, hearer_successes) // Ensure non-negative

		apply_presence_overlay(hearer)
		affected_targets[hearer] = hearer_successes

		to_chat(hearer, span_hypnophrase("You find yourself completely submitting to the Majesty of [owner]. Their every word is your utmost priority, every frown of displeasure crushing your soul. You find yourself humbling yourself entirely in their overwhelming presence."))

		if(hearer_successes > 0)
			to_chat(hearer, span_info("Despite the overwhelming presence, your will allows you to make [hearer_successes] contradictory action\s until youre allowed to leave [owner]'s company."))

	var/total_affected = length(affected_targets)
	to_chat(owner, span_warning(total_affected > 0 ? "Your Majesty overwhelms [total_affected] individual\s in your presence!" : "No one is present to witness your Majesty."))

/datum/discipline_power/presence/majesty/deactivate(mob/living/carbon/human/target)
	. = ..()
	for(var/mob/living/carbon/human/affected_target in affected_targets)
		if(affected_target)
			affected_target.remove_overlay(MUTATIONS_LAYER)
			to_chat(affected_target, span_hypnophrase("The overwhelming presence of [owner] fades, and your will returns to normal."))
	affected_targets.Cut()

// LOVE
/datum/discipline_power/presence/love
	name = "Love"
	desc = "Make someone enamored with you as if in a blood bond."
	level = 6
	check_flags = DISC_CHECK_CAPABLE|DISC_CHECK_SPEAK
	target_type = TARGET_HUMAN
	range = 7
	cooldown_length = 15 SECONDS
	var/presence_succeeded = FALSE

/datum/discipline_power/presence/love/pre_activation_checks(mob/living/target)
	if(!presence_hearing_check(owner, target))
		return FALSE

	presence_succeeded = presence_check(owner, target)
	if(presence_succeeded)
		return TRUE

	do_cooldown(cooldown_length)
	return FALSE

/datum/discipline_power/presence/love/activate(mob/living/carbon/human/target)
	. = ..()
	if(presence_succeeded)
		apply_presence_overlay(target)
		target.apply_status_effect(STATUS_EFFECT_INLOVE, owner)
		to_chat(owner, span_warning("You've enthralled [target] with your presence, and bonded them to you!"))
	else
		to_chat(owner, span_warning("[target]'s mind has resisted your attempt to sway!"))
		to_chat(target, span_warning("An overwhelming aura radiates from [owner], compelling your love… but you steel your heart and turn away from their unnatural allure."))

// Helper procs
/mob/living/carbon/proc/walk_to_caster(mob/living/step_to)
	walk(src, 0)
	if(!CheckFrenzyMove())
		set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
		step_to(src, step_to, 0)
		face_atom(step_to)

/mob/living/carbon/human/proc/step_away_caster(mob/living/step_from)
	walk(src, 0)
	if(!CheckFrenzyMove())
		set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
		step_away(src, step_from, 99)
