/proc/get_business_by_name(name) //Compares a business 'B' to the master list and returns the business if found.
	for(var/datum/business/B in GLOB.all_businesses)
		if(B.name == name)
			return B

/proc/get_business_by_biz_uid(uid)
	for(var/datum/business/B in GLOB.all_businesses)
		if(B.business_uid == uid)
			return B

/proc/get_business_by_owner_uid(uid)
	for(var/datum/business/B in GLOB.all_businesses)
		if(!B.owner)
			continue
		if(B.owner.unique_id == uid)
			return B

/datum/business/proc/try_auth_business(pass)
	if(access_password == pass)
		return TRUE
	return FALSE

/datum/business/proc/get_owner_name()
	if(!owner)
		return "No Owner"

	return owner.name

/datum/business/proc/get_owner()
	return owner

/datum/business/proc/get_owner_uid()
	if(!owner)
		return
	return owner.unique_id

/datum/business/proc/get_status()
	if(suspended)
		return BUSINESS_SUSPENDED

	return BUSINESS_ACTIVE

/datum/business/proc/get_department()
	return dept_by_id(department)

/datum/business/proc/get_department_id()
	var/datum/department/D = get_department()
	if(D)
		return D.id

/proc/businesses_by_category(cat)
	RETURN_TYPE(/list)

	var/list/biz = list()
	for(var/datum/business/B in GLOB.all_businesses)
		if(cat in B.categories)
			biz += B

	return biz

/datum/business/proc/is_department_employee(uid, mob/living/carbon/human/H)
	for(var/datum/job/J in get_jobs())
		if(J.exclusive_employees.Find(uid))
			return TRUE

	if(H)
		var/datum/data/record/record
		for(var/datum/data/record/R in GLOB.data_core.general)
			if(H.client.prefs.unique_id == R.fields["unique_id"])
				record = R
		if(record)
			var/datum/job/J = SSjob.GetJob(record.fields["real_rank"])
			if(J && (J in business_jobs))
				return TRUE

	return FALSE

