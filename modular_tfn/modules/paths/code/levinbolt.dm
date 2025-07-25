/datum/discipline/path/levinbolt
	name = "Path of the Levinbolt"
	desc = "A rudimentary path of Thaumaturgy that allows the manipulation of lightning. Violates Masquerade."
	icon_state = "flames"
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
	cooldown_length = 1 SECONDS
	violates_masquerade = TRUE

/datum/discipline_power/path/levinbolt/two/activate(mob/living/target)
	. = ..()


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

//EYE OF THE STORM - Level 5
/datum/discipline_power/path/levinbolt/five
	name = "Eye of the Storm"
	desc = "Become charged with an incredible amount of energy."

	level = 5
	cooldown_length = 20 SECONDS
	violates_masquerade = TRUE

/datum/discipline_power/path/levinbolt/five/activate(atom/target)
	. = ..()
