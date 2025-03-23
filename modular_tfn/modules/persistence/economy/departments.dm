/datum/department
	var/name = "Department"
	var/id
	var/desc = "This is a generic department. Technically you shouldn't see this."

	var/dept_type = PUBLIC_DEPARTMENT

	var/dept_color = COLOR_GRAY

	var/list/blacklisted_employees = list()	// employees are added here by UID (unique id)

	var/list/categories = list()

/datum/department/proc/get_categories()
	var/datum/business/B = get_business()

	if(!B)
		return categories

	return B.categories

/datum/department/New(d_name, d_type, d_id, d_desc)
	..()
	if(d_name)
		name = d_name
	if(d_type)
		dept_type = d_type
	if(d_id)
		id = d_id
	if(d_desc)
		desc = d_desc

	sanitize_values()

/datum/department/proc/sanitize_values()	// juuuust in case shittery happens.
	if(!blacklisted_employees)
		blacklisted_employees = list()

	if(!categories)
		categories = list()

	if(get_business())
		dept_type = BUSINESS_DEPARTMENT

	GLOB.departments |= src

	switch(dept_type)
		if(PUBLIC_DEPARTMENT)
			GLOB.public_departments |= src
		if(PRIVATE_DEPARTMENT)
			GLOB.private_departments |= src
		if(EXTERNAL_DEPARTMENT)
			GLOB.external_departments |= src
		if(HIDDEN_DEPARTMENT)
			GLOB.hidden_departments |= src
		if(BUSINESS_DEPARTMENT)
			GLOB.business_departments |= src

	return TRUE

/proc/dept_name_by_id(id)
	for(var/datum/department/D in GLOB.departments)
		if(id == D.id)
			return D.name

/proc/dept_by_id(id)
	RETURN_TYPE(/datum/department)

	for(var/datum/department/D in GLOB.departments)
		if(id == D.id)
			return D

/proc/dept_by_name(name)
	RETURN_TYPE(/datum/department)

	for(var/datum/department/D in GLOB.departments)
		if(name == D.name)
			return D

/datum/department/proc/get_all_jobs()
	RETURN_TYPE(/list)

	var/list/dept_jobs = list()
	for(var/datum/job/J in SSjob.occupations)
		if(J.department == id)
			dept_jobs += J

	return dept_jobs

/datum/department/proc/get_available_jobs(mob/dead/new_player/np)
	RETURN_TYPE(/list)

	var/list/all_jobs = list()
	for(var/datum/job/J in get_all_jobs())
		if(!np.IsJobUnavailable(J.title))
			continue
		all_jobs += J

	return all_jobs

/datum/department/proc/get_business()
	RETURN_TYPE(/datum/business)

	for(var/datum/business/B in GLOB.all_businesses)
		if(B.business_uid == id)
			return B
