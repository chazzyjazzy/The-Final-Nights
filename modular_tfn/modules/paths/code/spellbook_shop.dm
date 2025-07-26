/obj/machinery/mineral/equipment_vendor/fastfood/occult
	owner_needed = FALSE
	desc = "Use your occult research to reap the benefits of safeguarded knowledge and artifacts."
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
