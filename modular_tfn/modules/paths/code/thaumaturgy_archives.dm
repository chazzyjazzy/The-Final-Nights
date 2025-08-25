/obj/machinery/mineral/equipment_vendor/fastfood/occult
	owner_needed = FALSE
	desc = "Use your occult research to reap the benefits of safeguarded knowledge and artifacts."
	dispenses_dollars = FALSE
	prize_list = list(new /datum/data/mining_equipment("Lure of Flames Spellbook (Level I)",	/obj/item/path_spellbook/lure_of_flames/level1,	10),
		new /datum/data/mining_equipment("Lure of Flames Spellbook (Level II)",	/obj/item/path_spellbook/lure_of_flames/level2,	10),
		new /datum/data/mining_equipment("Lure of Flames Spellbook (Level III)",	/obj/item/path_spellbook/lure_of_flames/level3,	10),
		new /datum/data/mining_equipment("Lure of Flames Spellbook (Level IV)",	/obj/item/path_spellbook/lure_of_flames/level4,	10),
		new /datum/data/mining_equipment("Lure of Flames Spellbook (Level V)",	/obj/item/path_spellbook/lure_of_flames/level5,	10),
		new /datum/data/mining_equipment("Levinbolt Spellbook (Level I)",	/obj/item/path_spellbook/levinbolt/level1,	10),
		new /datum/data/mining_equipment("Levinbolt Spellbook (Level II)",	/obj/item/path_spellbook/levinbolt/level2,	10),
		new /datum/data/mining_equipment("Levinbolt Spellbook (Level III)",	/obj/item/path_spellbook/levinbolt/level3,	10),
		new /datum/data/mining_equipment("Levinbolt Spellbook (Level IV)",	/obj/item/path_spellbook/levinbolt/level4,	10),
		new /datum/data/mining_equipment("Levinbolt Spellbook (Level V)",	/obj/item/path_spellbook/levinbolt/level5,	10),
		new /datum/data/mining_equipment("Random Occult Artifact", /obj/item/vtm_artifact/rand, 10),
		new /datum/data/mining_equipment("Odious Chalice", /obj/item/vtm_artifact/odious_chalice, 10),
		new /datum/data/mining_equipment("Key of Alamut", /obj/item/vtm_artifact/key_of_alamut, 10),
		new /datum/data/mining_equipment("Daimonori", /obj/item/vtm_artifact/daimonori, 10),
		new /datum/data/mining_equipment("Bloodstar", /obj/item/vtm_artifact/bloodstar, 10),
		new /datum/data/mining_equipment("Heart of Eliza", /obj/item/vtm_artifact/heart_of_eliza, 10),
		new /datum/data/mining_equipment("Fae Charm", /obj/item/vtm_artifact/fae_charm, 10),
		new /datum/data/mining_equipment("Galdjum", /obj/item/vtm_artifact/galdjum, 10),
		new /datum/data/mining_equipment("Mummywrap Fetish", /obj/item/vtm_artifact/mummywrap_fetish, 10),
		new /datum/data/mining_equipment("Weekapaug Thistle", /obj/item/vtm_artifact/weekapaug_thistle, 10),
		new /datum/data/mining_equipment("Bloodstone", /obj/item/vtm_artifact/bloodstone, 10)
	)

// the world initializes vending products much earlier in the compilation order. have to add these items to GLOB.vending_products after GLOB.vending_products is initialized.
// perhaps this problem is solved if we just place the vendor in strongdmm. need to test this
/world/New()
	. = ..()
	GLOB.vending_products[/obj/item/path_spellbook/lure_of_flames/level1] = 1
	GLOB.vending_products[/obj/item/path_spellbook/lure_of_flames/level2] = 1
	GLOB.vending_products[/obj/item/path_spellbook/lure_of_flames/level3] = 1
	GLOB.vending_products[/obj/item/path_spellbook/lure_of_flames/level4] = 1
	GLOB.vending_products[/obj/item/path_spellbook/lure_of_flames/level5] = 1
	GLOB.vending_products[/obj/item/path_spellbook/levinbolt/level1] = 1
	GLOB.vending_products[/obj/item/path_spellbook/levinbolt/level2] = 1
	GLOB.vending_products[/obj/item/path_spellbook/levinbolt/level3] = 1
	GLOB.vending_products[/obj/item/path_spellbook/levinbolt/level4] = 1
	GLOB.vending_products[/obj/item/path_spellbook/levinbolt/level5] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/rand] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/odious_chalice] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/key_of_alamut] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/daimonori] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/bloodstar] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/heart_of_eliza] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/fae_charm] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/galdjum] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/mummywrap_fetish] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/weekapaug_thistle] = 1
	GLOB.vending_products[/obj/item/vtm_artifact/bloodstone] = 1

// SpellbookVendor.jsx in tgui/interfaces
/obj/machinery/mineral/equipment_vendor/fastfood/occult/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpellbookVendor", name)
		ui.open()

// Override ui_data to show user's research_points and knowledge data + tremere members
/obj/machinery/mineral/equipment_vendor/fastfood/occult/ui_data(mob/user)
	. = list()
	.["user"] = list()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		.["user"]["points"] = H.research_points
		.["user"]["name"] = "[H.name]"
		.["user"]["job"] = "[H.mind?.assigned_role]"
		.["user"]["has_thaumaturgy"] = HAS_TRAIT(H, TRAIT_THAUMATURGY_KNOWLEDGE)
		.["user"]["has_necromancy"] = H.necromancy_knowledge
		.["user"]["is_regent"] = (H.mind?.assigned_role == "Chantry Regent")
	else
		.["user"]["points"] = 0
		.["user"]["name"] = "Unknown"
		.["user"]["job"] = "Unknown"
		.["user"]["has_thaumaturgy"] = FALSE
		.["user"]["has_necromancy"] = FALSE
		.["user"]["is_regent"] = FALSE

	.["tremere_members"] = list()
	for(var/mob/living/carbon/human/tremere_member in GLOB.human_list)
		if(!tremere_member.mind)
			continue
		var/role = tremere_member.mind.assigned_role
		if(role in list("Chantry Archivist", "Chantry Gargoyle", "Chantry Regent"))
			.["tremere_members"] += list(list(
				"name" = tremere_member.name,
				"role" = role,
				"points" = tremere_member.research_points,
				"ref" = "\ref[tremere_member]"
			))

/obj/machinery/mineral/equipment_vendor/fastfood/occult/ui_act(action, params)
	if(action == "transfer_points")
		return handle_point_transfer(action, params)
	if(action == "seize_points")
		return handle_point_seizure(action, params)
	if(action != "purchase")
		return ..()

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	if(istype(H.dna.species, /datum/species/human))
		return

	var/datum/data/mining_equipment/prize = locate(params["ref"]) in prize_list
	if(!prize || !(prize in prize_list))
		to_chat(usr, span_alert("Error: Invalid choice!"))
		flick(icon_deny, src)
		return

	if(prize.cost > H.research_points)
		to_chat(usr, span_alert("Error: Insufficient research points for [prize.equipment_name]! You need [prize.cost] research points."))
		flick(icon_deny, src)
		return

	// deduct research points from purchase
	H.research_points -= prize.cost
	to_chat(usr, span_notice("The Archives emanate dark energy as it dispenses [prize.equipment_name]!"))
	new prize.equipment_path(loc)
	SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
	return TRUE

//transfer research points
/obj/machinery/mineral/equipment_vendor/fastfood/occult/proc/handle_point_transfer(action, params)
	if(!ishuman(usr))
		return FALSE

	var/mob/living/carbon/human/sender = usr
	var/target_ref = params["target_ref"]
	var/amount = text2num(params["amount"])

	if(!target_ref || !amount || amount <= 0)
		to_chat(sender, span_alert("Error: Invalid transfer parameters!"))
		return FALSE

	if(amount > sender.research_points)
		to_chat(sender, span_alert("Error: You don't have enough research points!"))
		return FALSE

	var/mob/living/carbon/human/target = locate(target_ref)
	if(!target || !ishuman(target))
		to_chat(sender, span_alert("Error: Target not found!"))
		return FALSE

	// Verify target is still a valid Tremere member
	if(!(target.mind?.assigned_role in list("Chantry Archivist", "Chantry Gargoyle", "Tremere Regent")))
		to_chat(sender, span_alert("Error: Target is no longer a valid recipient!"))
		return FALSE

	// Perform the transfer
	sender.research_points -= amount
	target.research_points += amount

	to_chat(sender, span_notice("You transfer [amount] research points to [target.name] through the Archives' dark conduits."))
	to_chat(target, span_notice("The Archives whisper to you... [sender.name] has sent you [amount] research points."))

	return TRUE

//research point seizure
/obj/machinery/mineral/equipment_vendor/fastfood/occult/proc/handle_point_seizure(action, params)
	if(!ishuman(usr))
		return FALSE

	var/mob/living/carbon/human/regent = usr

	if(regent.mind?.assigned_role != "Tremere Regent")
		to_chat(regent, span_alert("Error: Only the Regent may exercise such authority!"))
		return FALSE

	var/target_ref = params["target_ref"]
	var/amount = text2num(params["amount"])

	if(!target_ref || !amount || amount <= 0)
		to_chat(regent, span_alert("Error: Invalid seizure parameters!"))
		return FALSE

	var/mob/living/carbon/human/target = locate(target_ref)
	if(!target || !ishuman(target))
		to_chat(regent, span_alert("Error: Target not found!"))
		return FALSE

	// verify target is a valid Tremere member
	if(!(target.mind?.assigned_role in list("Chantry Archivist", "Chantry Gargoyle", "Tremere Regent")))
		to_chat(regent, span_alert("Error: Target is not a Tremere clan member!"))
		return FALSE

	// can't seize more than they have
	var/actual_amount = min(amount, target.research_points)

	if(actual_amount <= 0)
		to_chat(regent, span_alert("Error: Target has no research points to seize!"))
		return FALSE

	// Perform the seizure
	target.research_points -= actual_amount
	regent.research_points += actual_amount

	to_chat(regent, span_notice("By your authority as Regent, you seize [actual_amount] research points from [target.name] through the Archives."))
	to_chat(target, span_warning("The Archives grow cold... Regent [regent.name] has seized [actual_amount] of your research points by right of authority."))

	return TRUE

// Remove the AltClick dollar dispensing
/obj/machinery/mineral/equipment_vendor/fastfood/occult/AltClick(mob/user)
	return

//offer artifacts to the shop for research points
/obj/machinery/mineral/equipment_vendor/fastfood/occult/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/vtm_artifact))
		var/obj/item/vtm_artifact/artifact = W

		if(!ishuman(user))
			to_chat(user, span_warning("The Archives reject your offering."))
			return

		var/mob/living/carbon/human/H = user

		if(artifact.research_value <= 0)
			to_chat(user, span_warning("The Archives find no value in this artifact."))
			return

		H.research_points += artifact.research_value

		if(artifact.research_value >= 20)
			to_chat(user, span_nicegreen("The Archives hungrily consume the powerful artifact, granting you [artifact.research_value] research points!"))
		else if(artifact.research_value >= 10)
			to_chat(user, span_notice("The Archives absorb the artifact's essence, granting you [artifact.research_value] research points."))
		else
			to_chat(user, span_notice("The Archives reluctantly accept the minor artifact, granting you [artifact.research_value] research points."))

		qdel(artifact)

		return TRUE

	// Fall back to default behavior for non-artifacts
	return ..()

// TODO : special shop for necromancers
