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
	)

// the world initializes vending products much earlier in the compilation order. have to add these items to GLOB.vending_products after GLOB.vending_products is initialized.
// perhaps this problem is solved if we just place the vendor in strongdmm. need to test this
/world/New()
	. = ..()
	// Add occult vendor items to vending products before sprite sheet generation
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

// SpellbookVendor.jsx in tgui/interfaces
/obj/machinery/mineral/equipment_vendor/fastfood/occult/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpellbookVendor", name)
		ui.open()

// Override ui_data to show user's research_points and knowledge data
/obj/machinery/mineral/equipment_vendor/fastfood/occult/ui_data(mob/user)
	. = list()
	.["user"] = list()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		.["user"]["points"] = H.research_points
		.["user"]["name"] = "[H.name]"
		.["user"]["job"] = "[H.mind?.assigned_role]"
		.["user"]["has_thaumaturgy"] = H.thaumaturgy_knowledge
		.["user"]["has_necromancy"] = H.necromancy_knowledge
	else
		.["user"]["points"] = 0
		.["user"]["name"] = "Unknown"
		.["user"]["job"] = "Unknown"
		.["user"]["has_thaumaturgy"] = FALSE
		.["user"]["has_necromancy"] = FALSE

// Override ui_act to use research_points instead of vendor points (dollars)
/obj/machinery/mineral/equipment_vendor/fastfood/occult/ui_act(action, params)
	if(action != "purchase")
		return ..()

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	var/datum/data/mining_equipment/prize = locate(params["ref"]) in prize_list
	if(!prize || !(prize in prize_list))
		to_chat(usr, span_alert("Error: Invalid choice!"))
		flick(icon_deny, src)
		return

	if(prize.cost > H.research_points)
		to_chat(usr, span_alert("Error: Insufficient research points for [prize.equipment_name]! You need [prize.cost] research points."))
		flick(icon_deny, src)
		return

	// Deduct research points from user
	H.research_points -= prize.cost
	to_chat(usr, span_notice("emanates dark energy as it dispenses [prize.equipment_name]!"))
	new prize.equipment_path(loc)
	SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
	return TRUE

// Remove the AltClick dollar dispensing for this vendor
/obj/machinery/mineral/equipment_vendor/fastfood/occult/AltClick(mob/user)
	return  // Do nothing
