/datum/business_person
	var/name = "Unknown Business Person"
	var/unique_id = " "

/datum/business_person/New(n_name, uid)

	if(n_name)
		name = n_name
	if(uid)
		unique_id = uid

	..()
