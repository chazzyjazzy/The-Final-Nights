GLOBAL_LIST_EMPTY(all_money_accounts)
GLOBAL_LIST_EMPTY(transaction_devices)
GLOBAL_LIST_EMPTY(money_displays)

GLOBAL_LIST_EMPTY(department_cards)

// all departments
GLOBAL_LIST_EMPTY(departments)

GLOBAL_LIST_EMPTY(public_departments)
GLOBAL_LIST_EMPTY(private_departments)
GLOBAL_LIST_EMPTY(business_departments)
GLOBAL_LIST_EMPTY(external_departments)
GLOBAL_LIST_EMPTY(hidden_departments)

// the department's bank accounts
GLOBAL_LIST_EMPTY(department_accounts)

GLOBAL_LIST_EMPTY(public_department_accounts)
GLOBAL_LIST_EMPTY(private_department_accounts)
GLOBAL_LIST_EMPTY(external_department_accounts)
GLOBAL_LIST_EMPTY(hidden_department_accounts)
GLOBAL_LIST_EMPTY(business_department_accounts)

GLOBAL_VAR_INIT(num_financial_terminals, 1)
GLOBAL_VAR_INIT(economy_init, 0)

GLOBAL_VAR(current_date_string)
// businesses

GLOBAL_LIST_EMPTY(all_businesses)
GLOBAL_LIST_EMPTY(all_business_accesses)
GLOBAL_LIST_EMPTY(business_ids)

GLOBAL_LIST_INIT(business_categories, list( // list of categories businesses can list themselves as
	CAT_ADS,
	CAT_FARM,
	CAT_LIBRARY,
	CAT_BUILDING,
	CAT_EDU,
	CAT_EMPLOY,
	CAT_ENTERTAINMENT,
	CAT_CATERING,
	CAT_DRINKS,
	CAT_HOSPITALITY,
	CAT_LEISURE,
	CAT_MANUFACTURE,
	CAT_MOTOR,
	CAT_NEWS,
	CAT_HEALTH,
	CAT_RETAIL,
	CAT_JANITOR,
	CAT_SEC,
	CAT_TECH,
	CAT_SOCIAL,
	CAT_MINING,
	CAT_GUNS,
))

GLOBAL_LIST_INIT(license_business_categories, list( // so people stop cheesing this, i'll figure it out another time
	CAT_BANK,
	CAT_LEGAL,
))


GLOBAL_LIST_INIT(hidden_categories, list( // list of categories businesses cannot list themselves as
	CAT_HARD_DRUGS,
	CAT_BLACKMARKET,
	CAT_PIRACY,
	CAT_INFOLEAKS,
	CAT_POLITICALTRAD,
	CAT_POLITICALREVO,
	CAT_POLITICALCONSPIRACY,
	CAT_POLITICSSTATE,
	CAT_POLITICSFED,
))
/*
GLOBAL_LIST_INIT(business_outfits, list(
	"Formal" = list("path" = /decl/hierarchy/outfit/job/business/formal),
	"Journalist" = list("path" = /decl/hierarchy/outfit/job/business/journalist),
	"Chaplain" = list("path" = /decl/hierarchy/outfit/job/business/priest),
	"Explorer" = list("path" = /decl/hierarchy/outfit/job/business/explorer),
	"Barber" = list("path" = /decl/hierarchy/outfit/job/business/barber),
	"Mailman" = list("path" = /decl/hierarchy/outfit/job/business/mailman),
	"Doctor" = list("path" = /decl/hierarchy/outfit/job/business/doctor),
	"Nurse" = list("path" = /decl/hierarchy/outfit/job/business/nurse),
	"Scientist" = list("path" = /decl/hierarchy/outfit/job/business/scientist),
	"Engineer" = list("path" = /decl/hierarchy/outfit/job/business/engineer),
	"Business Casual" = list("path" = /decl/hierarchy/outfit/job/business/casual),
	"High End Waiter (Red)" = list("path" = /decl/hierarchy/outfit/job/business/bartender/waiter/red),
	"High End Waiter (Grey)" = list("path" = /decl/hierarchy/outfit/job/business/bartender/waiter/grey),
	"High End Waiter (Brown)" = list("path" = /decl/hierarchy/outfit/job/business/bartender/waiter/brown),
	"Clown" = list("path" = /decl/hierarchy/outfit/job/business/clown),
	"Mime" = list("path" = /decl/hierarchy/outfit/job/business/mime)
))
*/
