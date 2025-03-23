/datum/controller/subsystem/persistence/proc/save_all_businesses()
	save_bizlist()

	for(var/datum/business/B in GLOB.all_businesses)
		B.save_business()

	return TRUE

/datum/controller/subsystem/persistence/proc/load_all_businesses()
	load_bizlist()

	for(var/V in GLOB.business_ids)
		if(!V || isnull(V))
			continue
		var/datum/business/B = new /datum/business(dept = "[V]")
		B.business_uid = V
		B.load_business()

	return TRUE

/datum/controller/subsystem/persistence/proc/save_bizlist()
	var/json_file = file("data/persistent/business_list.json")

	for(var/datum/business/B in GLOB.all_businesses)
		GLOB.business_ids |= B.business_uid

	listclearnulls(GLOB.business_ids)

	var/list/file_data = list()
	file_data = GLOB.business_ids
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/load_bizlist()
	var/json = file2text("data/persistent/business_list.json")
	if(!json)
		var/json_file = file("data/persistent/business_list.json")
		if(!fexists(json_file))
			WARNING("Failed to load business list. File likely corrupt.")
			return
		return
	GLOB.business_ids = json_decode(json)

	if(!GLOB.business_ids)
		GLOB.business_ids = list()

	listclearnulls(GLOB.business_ids)

/datum/business/proc/save_business()
	var/json_file = file("data/persistent/businesses/[business_uid].json")

	sanitize_business()

	var/list/data = list()

	data["name"] = name
	data["description"] = description
	data["categories"] = categories
	data["creation_date"] = creation_date
	data["business_uid"] = business_uid
	data["suspended"] = suspended
	data["suspended_reason"] = suspended_reason
	data["blacklisted_employees"] = blacklisted_employees
	data["blacklisted_ckeys"] = blacklisted_ckeys
	data["access_password"] = access_password
	data["department"] = department
	data["business_jobs"] = business_jobs
	data["business_accesses"] = business_accesses

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(data))

	return TRUE

/datum/business/proc/load_business()
	var/json_file = file("data/persistent/businesses/[business_uid].json")

	if(!fexists(json_file))
		return

	var/list/json = json_decode(file2text(json_file))

	if(!json)
		return

	var/list/file_data = json["data"]

	name = file_data["name"]
	description = file_data["description"]
	categories = file_data["categories"]
	creation_date = file_data["creation_date"]
	business_uid = file_data["business_uid"]
	suspended = file_data["suspended"]
	suspended_reason = file_data["suspended_reason"]
	blacklisted_employees = file_data["blacklisted_employees"]
	blacklisted_ckeys = file_data["blacklisted_ckeys"]
	access_password = file_data["access_password"]
	department = file_data["department"]
	business_jobs = file_data["business_jobs"]
	business_accesses = file_data["business_accesses"]

	sanitize_business(business_uid)

	return TRUE
