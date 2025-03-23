/*
 * Anesthetic
 */
/obj/item/anesthetic_tank
	name = "anesthetic tank"
	desc = "A tank of anesthesia."
	icon_state = "anesthetic"
	inhand_icon_state = "an_tank"
	var/tank_holder_icon_state = "holder_oxygen_anesthetic"
	force = 10

/obj/item/anesthetic_tank/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)

/obj/item/anesthetic_tank/attack_self(mob/user)
	. = ..()
	if(ishumanbasic(user))
		user.SetSleeping(15 SECONDS)
