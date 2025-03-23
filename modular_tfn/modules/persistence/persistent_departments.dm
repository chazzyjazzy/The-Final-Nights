/datum/controller/subsystem/economy/proc/save_business_departments()
	var/path = "data/persistent/departments/business_departments.sav"

	var/savefile/S = new /savefile(path)
	if(!fexists(path))
		return FALSE
	if(!S)
		return FALSE
	S.cd = "/"

	for(var/datum/department/D in GLOB.business_departments)
		D.sanitize_values()

	WRITE_FILE(S, GLOB.business_departments)

	return TRUE

/datum/controller/subsystem/economy/proc/load_business_departments()
	var/path = "data/persistent/departments/business_departments.sav"

	var/savefile/S = new /savefile(path)
	if(!fexists(path))
		save_economy()
		return FALSE
	if(!S)
		return FALSE
	S.cd = "/"

	READ_FILE(S, GLOB.business_departments)

	if(!S || !GLOB.business_departments)
		GLOB.business_departments = list()
		return

	for(var/datum/department/D in GLOB.business_departments)
		D.sanitize_values()

	return TRUE

/datum/controller/subsystem/economy/proc/save_economy()
	if(!length(GLOB.departments))
		message_admins("Economy Subsystem error: No department accounts found. Unable to save.")
		return FALSE

	// save each department to a save file.
	for(var/datum/department/D in GLOB.departments)
		if(!D.name || !D.id)
			continue

		if(D.dept_type == BUSINESS_DEPARTMENT)
			continue

		D.sanitize_values()

		var/sav_folder = "public_departments"

		if(D.dept_type == PUBLIC_DEPARTMENT)
			sav_folder = "public_departments"
		if(D.dept_type == PRIVATE_DEPARTMENT)
			sav_folder = "private_departments"
		if(D.dept_type == EXTERNAL_DEPARTMENT)
			sav_folder = "external_departments"
		if(D.dept_type == HIDDEN_DEPARTMENT)
			sav_folder = "hidden_departments"

		var/path = "data/persistent/departments/[sav_folder]/[D.id].sav"

		var/savefile/S = new /savefile(path)
		if(!fexists(path))
			return FALSE
		if(!S)
			return FALSE
		S.cd = "/"

	save_business_departments()	// saved separately, for reasons

	return TRUE

/datum/controller/subsystem/economy/proc/load_economy()
	if(!length(GLOB.departments))
		message_admins("Economy Subsystem error: No department accounts found. Unable to load.")
		return FALSE

	// save each department to a save file.
	for(var/datum/department/D in GLOB.departments)
		if(!D.name || !D.id)
			continue

		var/sav_folder = "public_departments"

		if(D.dept_type == PUBLIC_DEPARTMENT)
			sav_folder = "public_departments"
		if(D.dept_type == PRIVATE_DEPARTMENT)
			sav_folder = "private_departments"
		if(D.dept_type == EXTERNAL_DEPARTMENT)
			sav_folder = "external_departments"
		if(D.dept_type == HIDDEN_DEPARTMENT)
			sav_folder = "hidden_departments"


		var/path = "data/persistent/departments/[sav_folder]/[D.id].sav"

		var/savefile/S = new /savefile(path)
		if(!fexists(path))
			var/new_path = "data/persistent/departments/[sav_folder]/[D.name].sav" //legacy loading
			if(!fexists(new_path))
				return FALSE
		if(!S)
			return FALSE
		S.cd = "/"

		D.sanitize_values()

	return TRUE


