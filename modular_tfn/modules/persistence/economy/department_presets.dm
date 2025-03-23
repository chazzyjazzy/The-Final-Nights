// ## Public Presets ## //

/datum/department/state
	name = "State"
	id = DEPT_CITY
	desc = "This is the State's funding account. Taxes go here."
	dept_color = "#1D1D4F"
	categories = list(CAT_POLITICSSTATE)

/datum/department/public
	name = "Public"
	id = DEPT_PUBLIC
	desc = "The public funding account. This pays welfare to unemployed, disabled or providing vacation pay to off-duty coucil members, also may fund any jobs that are government supported."
	dept_color = "#468047"

/datum/department/maintenance
	name = "Maintenance"
	id = DEPT_MAINTENANCE

	desc = "The maintenance department is paid from this budget. Any city works fees are also paid into this account."
	dept_color = "#9c6c2d"
	categories = list(CAT_JANITOR, CAT_MANUFACTURE, CAT_BUILDING)

/datum/department/police
	name = "Police"
	id = DEPT_POLICE
	desc = "The police department is funded by this account. Money made from fines are paid into this account."
	dept_color = "#7a2a2a"
	categories = list(CAT_SEC, CAT_PRISON_MINING)

// ## Private Presets ## //

/datum/department/healthcare
	name = "Healthcare"
	id = DEPT_PRIVATE_HEALTHCARE
	desc = "The hospital and its employees are paid from this account. Any provided medical vendors, medications, treatments and surgeries are income for this department."
	dept_type = PRIVATE_DEPARTMENT
	dept_color = "#457c7d"
	categories = list(CAT_HEALTH)

/datum/department/warehouse
	name = "Warehouse"
	id = DEPT_WAREHOUSE
	desc = "The Warehouse and its employees."
	dept_type = PRIVATE_DEPARTMENT
	dept_color = "#7a4f33"
	categories = list(CAT_MANUFACTURE, CAT_RETAIL, CAT_JANITOR, CAT_BUILDING, CAT_MINING, CAT_DRINKS, CAT_FOOD, CAT_FARM, CAT_NEWS)

// ## External Presets

/datum/department/fed
	name = "Federal Government"
	id = DEPT_FED
	desc = "The Federal Government."
	dept_type = EXTERNAL_DEPARTMENT
	dept_color = "#787654"
	categories = list(CAT_POLITICSSTATE)


// ## Faction Departments (hidden)

/datum/department/template
	name = "template"
	id = DEPT_CAMARILLA
	desc = "template"
	dept_type = HIDDEN_DEPARTMENT
	categories = list(CAT_POLITICALREVO)
