//Wonder recipes
//NOTE: Wonders are named after their proper keys, the wonder structure handles that code
/datum/crafting_recipe/structure/wonder
	name = "wonder"
	time = 60 SECONDS
	reqs = list(
		/obj/item/bodypart = 2,
		/obj/item/organ/stomach = 1,
	)
	result = /obj/structure/wonder
	always_available = FALSE
	category = CAT_MARAUDER
	subcategory = CAT_WONDERS

	var/datum/weakref/original_bodypart_owner
	var/datum/weakref/organ_owner

/datum/crafting_recipe/structure/wonder/check_requirements(mob/user, list/collected_requirements)
	for(var/obj/item/bodypart/usable_limb in collected_requirements[/obj/item/bodypart])
		original_bodypart_owner = WEAKREF(usable_limb.original_owner)
		var/mob/living/carbon/human/resolved_bodypart_owner = original_bodypart_owner?.resolve()

		if(isnull(resolved_bodypart_owner))
			return FALSE
		if(isnpc(resolved_bodypart_owner))
			to_chat(user, span_boldwarning("I CAN'T USE THESE BODY PARTS!"))
			return FALSE

	for(var/obj/item/organ/usable_organ in collected_requirements[/obj/item/organ])
		organ_owner = WEAKREF(usable_organ.owner)
		var/mob/living/carbon/human/resolved_organ_owner = organ_owner?.resolve()

		if(isnull(resolved_organ_owner))
			return FALSE
		if(isnpc(resolved_organ_owner))
			to_chat(user, span_boldwarning("I CAN'T USE THESE ORGANS!"))
			return FALSE

	return TRUE

/datum/crafting_recipe/structure/wonder/first
	name = "first wonder (2 bodyparts, 1 stomach)"
	result = /obj/structure/wonder
	reqs = list(
		/obj/item/bodypart = 2,
		/obj/item/organ/stomach = 1,
	)

/datum/crafting_recipe/structure/wonder/second
	name = "second wonder (2 bodyparts, 2 lungs)"
	result = /obj/structure/wonder
	reqs = list(
		/obj/item/bodypart = 2,
		/obj/item/organ/lungs = 2,
	)

/datum/crafting_recipe/structure/wonder/third
	name = "third wonder (2 bodyparts, 3 heads, 2 stomachs)"
	result = /obj/structure/wonder
	reqs = list(
		/obj/item/bodypart/head = 3,
		/obj/item/bodypart = 2,
		/obj/item/organ/stomach = 2,
	)

/datum/crafting_recipe/structure/wonder/fourth
	name = "fourth wonder (4 tongues, 3 eyes, 4 livers)"
	result = /obj/structure/wonder
	reqs = list(
		/obj/item/organ/tongue = 4,
		/obj/item/organ/eyes = 3,
		/obj/item/organ/liver = 4,
	)

//Wonder structure
/obj/structure/wonder
	name = "wonder"
	desc = "What a disgusting thing, what type of maniac would make this!?"
	icon = 'code/modules/antagonists/maniac/icons/creations.dmi'
	icon_state = "creation1"
	resistance_flags = INDESTRUCTIBLE
	density = TRUE
	anchored = TRUE
	// TODO: make this into a weakref?
	/// The maniac that made this structure,
	var/datum/antagonist/marauder/dream_master
	/// Index of the wonder
	var/wonder_id = 1
	/// Wonder ID descriptor
	var/wonder_id_desc = "FIRST"
	/// Whether or not we have been gazed at
	var/gazed_at = FALSE
	/// Dreamer key number
	var/key_num = ""
	/// Dreamer key text
	var/key_text = ""

/obj/structure/wonder/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/wonder/OnCrafted(dirin, mob/user)
	. = ..()
	playsound(src, 'code/modules/antagonists/maniac/sounds/wonder.ogg', 100, vary = FALSE)
	dream_master = IS_MARAUDER(user)
	if(dream_master)
		if(LAZYACCESS(dream_master.recipe_progression, dream_master.current_wonder))
			user.mind.forget_crafting_recipe(dream_master.recipe_progression[dream_master.current_wonder])
		wonder_id = dream_master.current_wonder
		switch(wonder_id)
			if(1)
				wonder_id_desc = "FIRST"
			if(2)
				wonder_id_desc = "SECOND"
			if(3)
				wonder_id_desc = "THIRD"
			if(4)
				wonder_id_desc = "FOURTH"
		if(wonder_id >= 4)
			if(GLOB.maniac_highlander) // Has a Maniac already TRIUMPHED?
				to_chat(user, span_danger("IT WAS ALL FOR NAUGHT! I CAN'T WAKE UP!"))
			else
				to_chat(user, span_userdanger("I must SUM the keys. I am WAKING up!"))
				dream_master.agony(user)
				for(var/mob/living/carbon/C in GLOB.carbon_list - user) // Notify any other marauders
					var/datum/antagonist/marauder/competitor = IS_MARAUDER(C)
					if(competitor)
						to_chat(C, span_userdanger("The WORLD is crumbling. I must make HASTE and SUM the keys!"))
		key_num = LAZYACCESS(dream_master.num_keys, wonder_id)
		key_text = LAZYACCESS(dream_master.key_nums, wonder_id)
		name = "Wonder[key_text ? " [key_text]" : ""]"
		icon_state = "creation[clamp(wonder_id, 1, 4)]"
		dream_master.current_wonder++
		if(LAZYACCESS(dream_master.recipe_progression, dream_master.current_wonder))
			user.mind.teach_crafting_recipe(dream_master.recipe_progression[dream_master.current_wonder])
		dream_master.wonders_made |= src
		user.log_message("crafted [wonder_id_desc] Maniac Wonder [key_text].", LOG_GAME)
		message_admins("[wonder_id_desc] Maniac Wonder [key_text] constructed. [ADMIN_JMP(src)]")
	START_PROCESSING(SSobj, src)

/obj/structure/wonder/examine(mob/user)
	. = ..()
	// TODO: make this a weakref?
	if(!QDELETED(dream_master))
		var/maniac_datum = IS_MARAUDER(user)
		if(isAdminObserver(user))
			// TODO: make this a weakref?
			var/datum/mind/maniac_mind
			if(!QDELETED(dream_master.owner))
				maniac_mind = dream_master.owner
				var/seen_heart = LAZYACCESS(dream_master.hearts_seen, wonder_id)
				. += span_notice("This is the [wonder_id_desc] wonder of [maniac_mind.name ? maniac_mind.name : "*no name*"].")
				. += span_notice("Gazed at: [gazed_at ? "YES." : "NO."] Maniac knows this key: [seen_heart ? "YES." : "NO."]")
			return .
		if(maniac_datum == dream_master)
			if(!(user.stat == DEAD) && !isobserver(user))
				process()
			if(gazed_at)
				. += span_danger("They have GAZED at my [wonder_id_desc] wonder!")
			else
				. += span_warning("My [wonder_id_desc] wonder has gone unseen! They must GAZE upon it!")
			return .
		if(maniac_datum) // I love adminbus. Don't you?
			. += span_danger("My HEART recoils. This construction belongs to ANOTHER.")
			return .
		if(!ishuman(user))
			return .
		mark_victim(user)

/obj/structure/wonder/process()
	. = ..()
	var/list/viewers = view(7, src)
	if(!QDELETED(dream_master))
		for(var/mob/living/carbon/human/victim in viewers)
			var/manniaq = IS_MARAUDER(victim)
			if(!victim.mind || (victim.stat == DEAD) || manniaq)
				continue
			var/obj/item/organ/heart/heart = victim.getorganslot(ORGAN_SLOT_HEART)
			if(heart && !(dream_master in heart.maniacs)) //duplicate check because this NEEDS to mark a valid victim if available
				mark_victim(victim)
				break

/obj/structure/wonder/proc/mark_victim(mob/living/carbon/human/V)
	var/obj/item/organ/heart/H = V.getorganslot(ORGAN_SLOT_HEART)
	if(H && !QDELETED(dream_master))
		/*
		if(!length(H.maniacs))
			V.add_stress(/datum/stressevent/saw_wonder)
			V.add_curse(/datum/curse/schizophrenic, silent = TRUE) //let's not jumpscare normal people
		//	V.add_client_colour(/datum/client_colour/maniac_marked) //Hurt peoples's eyes, we instead give them zizo's curse which make them experience the maniac's hallucinations, how cool.
		*/
		if(!(dream_master in H.maniacs))
			var/inscryption = "[key_text] - [key_num]"
			LAZYSET(H.inscryptions, dream_master, inscryption)
			LAZYSET(H.inscryption_keys, dream_master, key_text)
			LAZYSET(H.maniacs2wonder_ids, dream_master, wonder_id)
			H.maniacs += dream_master
			V.emote("scream")
			V.blur_eyes(2)
			SEND_SOUND(V, 'code/modules/antagonists/maniac/sounds/seen_wonder.ogg')
			V.Paralyze(5 SECONDS)
			gazed_at = TRUE
			to_chat(V, span_userdanger("It is WONDERFUL!"))
			// TODO: weakref this
			var/hunting_marauder = dream_master.owner?.name
			V.log_message("was marked by Marauder [hunting_marauder ? "[hunting_marauder]'s " : ""]Wonder #[wonder_id]: \"[strip_html(inscryption)].\"", LOG_ATTACK)
