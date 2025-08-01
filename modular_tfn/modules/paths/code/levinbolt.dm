/datum/discipline/path/levinbolt
	name = "Path of the Levinbolt"
	desc = "A rudimentary path of Thaumaturgy that allows the manipulation of lightning. Violates Masquerade."
	icon_state = "levinbolt"
	power_type = /datum/discipline_power/path/levinbolt

/datum/discipline_power/path/levinbolt
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
/datum/discipline_power/path/levinbolt/one
	name = "Spark"
	desc = "Generate a small electrical discharge upon being struck."

	level = 1
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_CONSCIOUS
	violates_masquerade = FALSE
	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/path/levinbolt/three
	)

//when the owner is attacked by mob/living, mob/living has a 30% chance (or maybe a roll, or maybe more) to suffer a small stun. probably need to use signals, but there doesnt seem to be an appropriate one.
// todo : check /tg/ for appropriate signals, implement them

/datum/discipline_power/path/levinbolt/one/activate()
	. = ..()
	if(.)
		RegisterSignal(owner, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(spark_counter))

/datum/discipline_power/path/levinbolt/one/deactivate()
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_UNARMED_ATTACK)

/datum/discipline_power/path/levinbolt/one/proc/spark_counter(mob/source, obj/item/weapon, mob/living/attacker)
	if(prob(30))
		to_chat(world, "attacker is stunned")
		attacker.Stun(3 SECONDS)

//ILLUMINATE - Level 2
/datum/discipline_power/path/levinbolt/two
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

/datum/discipline_power/path/levinbolt/two/activate(mob/living/target)
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/lighter/levinbolt_arm(owner))
	owner.put_in_l_hand(new /obj/item/lighter/levinbolt_arm(owner))

/datum/discipline_power/path/levinbolt/two/deactivate()
	. = ..()
	// Remove levinbolt arm weapons
	for(var/obj/item/lighter/levinbolt_arm/illuminate in owner.held_items)
		qdel(illuminate)

// TODO: More powerful than spark, this should discharge a greater amount of energy around the user, stunning and also damaging attackers. (Visible to all)
//POWER ARRAY - Level 3
/datum/discipline_power/path/levinbolt/three
	name = "Power Array"
	desc = "Discharge a greater amount of energy around yourself."

	level = 3
	check_flags = DISC_CHECK_CAPABLE | DISC_CHECK_CONSCIOUS
	violates_masquerade = FALSE
	toggled = TRUE
	duration_length = 2 TURNS

	grouped_powers = list(
		/datum/discipline_power/path/levinbolt/one
	)

/datum/discipline_power/path/levinbolt/three/activate(mob/living/target)
	. = ..()

// TODO: This should be a powerful attack that channels a large amount of energy into three consecutive bolts, dealing burn damage.
//ZEUS' FURY - Level 4
/datum/discipline_power/path/levinbolt/four
	name = "Zeus' Fury"
	desc = "Build  up energy and direct it as arcs of lightning."

	level = 4
	cooldown_length = 10 SECONDS
	violates_masquerade = TRUE
	target_type = TARGET_LIVING
	range = 7

/datum/discipline_power/path/levinbolt/four/activate(mob/living/target)
	. = ..()

// TODO: Combination of some disciplines. It should flashbang everyone upon being activated, and allow them to shock others dramatically with their hand for a short duration.
//EYE OF THE STORM - Level 5
/datum/discipline_power/path/levinbolt/five
	name = "Eye of the Storm"
	desc = "Become charged with an incredible amount of energy."

	level = 5
	cooldown_length = 20 SECONDS
	violates_masquerade = TRUE

/datum/discipline_power/path/levinbolt/five/activate(atom/target)
	. = ..()
