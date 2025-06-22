// =============================================================================
// STOCK MARKET SYSTEM
// =============================================================================

// Market Configuration Constants
#define MARKET_UPDATE_INTERVAL 10 SECONDS
#define PRICE_HISTORY_LENGTH 360
#define BASE_MARKET_GROWTH 0.008   // Increased to 0.8% growth over 3 hours
#define VOLATILITY_MULTIPLIER 1.5  // Reduced from 2.5 to 1.5

// Sector definitions for correlation
#define SECTOR_TECH "Technology"
#define SECTOR_HEALTHCARE "Healthcare"
#define SECTOR_COMMODITIES "Commodities"
#define SECTOR_LOGISTICS "Logistics"
#define SECTOR_CORPORATE "Corporate"
#define SECTOR_FINANCE "Finance"

// =============================================================================
// CORE MARKET DATUM
// =============================================================================

/datum/stock_market
	var/list/stocks = list()
	var/list/sectors = list()
	var/market_index = 100.0
	var/list/market_history = list()
	var/market_sentiment = 0.0  // -1 to 1, affects all stocks
	var/last_update = 0
	var/round_start_time = 0
	var/list/active_terminals = list() // Track active terminals to send live updates to

/datum/stock_market/New()
	..()
	round_start_time = world.time
	initialize_sectors()
	generate_stocks()
	market_history += market_index
	START_PROCESSING(SSobj, src)

/datum/stock_market/proc/initialize_sectors()
	sectors = list(
		SECTOR_TECH = new /datum/stock_sector(SECTOR_TECH, 1.4, 0.6),        // Reduced volatility
		SECTOR_HEALTHCARE = new /datum/stock_sector(SECTOR_HEALTHCARE, 1.1, 0.5),
		SECTOR_COMMODITIES = new /datum/stock_sector(SECTOR_COMMODITIES, 1.6, 0.7), // Reduced volatility
		SECTOR_LOGISTICS = new /datum/stock_sector(SECTOR_LOGISTICS, 1.2, 0.4),
		SECTOR_CORPORATE = new /datum/stock_sector(SECTOR_CORPORATE, 1.0, 0.5),
		SECTOR_FINANCE = new /datum/stock_sector(SECTOR_FINANCE, 1.3, 0.6)    // Reduced volatility
	)

/datum/stock_market/proc/generate_stocks()
	// Tech Stocks
	create_stock("CyberDynastic Systems", "CDYN", SECTOR_TECH, rand(45, 85))
	create_stock("Nexus Technologies", "NXUS", SECTOR_TECH, rand(30, 70))
	create_stock("Quantum Computing Corporation", "QCOM", SECTOR_TECH, rand(120, 180))

	// Healthcare
	create_stock("BioGenex Medical", "BGEN", SECTOR_HEALTHCARE, rand(80, 120))
	create_stock("Pharma Medical Solutions Inc", "PHAR", SECTOR_HEALTHCARE, rand(60, 100))

	// Commodities
	create_stock("Demolitions Mining Co", "DMIN", SECTOR_COMMODITIES, rand(25, 45))
	create_stock("Executive Lumber", "ELUM", SECTOR_COMMODITIES, rand(35, 55))
	create_stock("Energy Dynamics", "ENDY", SECTOR_COMMODITIES, rand(70, 110))

	// Logistics
	create_stock("Giovanni & Co. Shipping", "SHIP", SECTOR_LOGISTICS, rand(40, 80))
	create_stock("Cargo International Ltd", "CRGO", SECTOR_LOGISTICS, rand(50, 90))

	// Corporate Giants
	create_stock("Endron Industries", "ENDR", SECTOR_CORPORATE, rand(150, 220))
	create_stock("Pentex Corporation", "PNTX", SECTOR_CORPORATE, rand(180, 250))
	create_stock("Millenium Group", "MILL", SECTOR_CORPORATE, rand(100, 160))

	// Finance
	create_stock("Mountain Stone Bank", "GBNK", SECTOR_FINANCE, rand(90, 130))
	create_stock("Investment Holdings", "INVH", SECTOR_FINANCE, rand(110, 170))

/datum/stock_market/proc/create_stock(name, ticker, sector, initial_price)
	var/datum/stock/S = new()
	S.name = name
	S.ticker = ticker
	S.sector = sector
	S.current_price = initial_price
	S.base_price = initial_price
	S.price_history = list(initial_price)
	S.market_ref = src
	stocks += S

/datum/stock_market/process()
	if(world.time - last_update < MARKET_UPDATE_INTERVAL)
		return

	last_update = world.time
	update_market_sentiment()
	update_sector_performance()
	update_all_stocks()
	update_market_index()
	trim_history()

	// Update all active terminals
	update_active_terminals()

/datum/stock_market/proc/update_market_sentiment()
	// Gradual shift in market sentiment with occasional volatility spikes
	var/sentiment_change = (rand(-10, 10) / 100.0)
	if(prob(2)) // 2% chance of major sentiment shift
		sentiment_change *= 3

	// Bias towards positive growth over the round
	var/round_progress = (world.time - round_start_time) / (3 HOURS)
	var/growth_bias = BASE_MARKET_GROWTH * (1 + round_progress) // Slightly increase growth over time

	// Apply mean reversion to sentiment
	var/mean_reversion = -market_sentiment * 0.1 // Pull back toward neutral

	market_sentiment += sentiment_change + growth_bias + mean_reversion
	market_sentiment = max(-1, min(1, market_sentiment))

/datum/stock_market/proc/update_sector_performance()
	for(var/sector_name in sectors)
		var/datum/stock_sector/sector = sectors[sector_name]
		sector.update_performance(market_sentiment)

/datum/stock_market/proc/update_all_stocks()
	for(var/datum/stock/stock in stocks)
		stock.update_price()

/datum/stock_market/proc/update_market_index()
	var/total_market_cap = 0
	var/total_change = 0

	for(var/datum/stock/stock in stocks)
		var/market_cap = stock.current_price * stock.outstanding_shares
		total_market_cap += market_cap
		if(stock.price_history.len >= 2)
			var/price_change = (stock.current_price - stock.price_history[stock.price_history.len-1]) / stock.price_history[stock.price_history.len-1]
			total_change += price_change * market_cap

	if(total_market_cap > 0)
		var/market_change = total_change / total_market_cap
		market_index *= (1 + market_change)

	market_history += market_index

/datum/stock_market/proc/trim_history()
	// Keep history to reasonable length
	if(market_history.len > PRICE_HISTORY_LENGTH)
		market_history.Cut(1, market_history.len - PRICE_HISTORY_LENGTH + 1)

/datum/stock_market/proc/get_stock_by_ticker(ticker)
	for(var/datum/stock/stock in stocks)
		if(stock.ticker == ticker)
			return stock
	return null

/datum/stock_market/proc/register_terminal(obj/machinery/computer/stockexchange/terminal)
	if(!(terminal in active_terminals))
		active_terminals += terminal

/datum/stock_market/proc/unregister_terminal(obj/machinery/computer/stockexchange/terminal)
	active_terminals -= terminal

/datum/stock_market/proc/update_active_terminals()
	for(var/obj/machinery/computer/stockexchange/terminal in active_terminals)
		if(terminal && !QDELETED(terminal))
			terminal.refresh_display()
		else
			active_terminals -= terminal

// =============================================================================
// STOCK SECTOR DATUM
// =============================================================================

/datum/stock_sector
	var/name = ""
	var/volatility = 1.0      // Multiplier for price movements
	var/correlation = 0.5     // How much stocks in sector move together
	var/performance = 0.0     // Current sector performance modifier

/datum/stock_sector/New(sector_name, vol, corr)
	name = sector_name
	volatility = vol
	correlation = corr

/datum/stock_sector/proc/update_performance(market_sentiment)
	// Sector performance influenced by market sentiment and random factors
	var/sentiment_effect = market_sentiment * 0.2 // Reduced from 0.3
	var/random_effect = (rand(-15, 15) / 100.0) * volatility // Reduced volatility
	var/mean_reversion = performance * -0.15 // Stronger mean reversion

	performance += sentiment_effect + random_effect + mean_reversion
	performance = max(-0.3, min(0.3, performance)) // Tighter bounds

// =============================================================================
// ENHANCED STOCK DATUM
// =============================================================================

/datum/stock
	var/name = ""
	var/ticker = ""
	var/sector = ""
	var/current_price = 50.0
	var/base_price = 50.0
	var/list/price_history = list()
	var/outstanding_shares = 1000000
	var/available_shares = 50000
	var/list/shareholders = list() // ckey -> shares owned
	var/momentum = 0.0 // Trending factor
	var/datum/stock_market/market_ref
	var/list/shareholder_purchase_data = list()

/datum/stock/proc/update_price()
	if(!market_ref)
		return

	var/datum/stock_sector/sector_data = market_ref.sectors[sector]
	if(!sector_data)
		return

	// Base random movement - reduced volatility
	var/base_change = (rand(-50, 50) / 100.0) * VOLATILITY_MULTIPLIER

	// Sector influence
	var/sector_influence = sector_data.performance * sector_data.correlation

	// Market sentiment influence
	var/sentiment_influence = market_ref.market_sentiment * 0.15

	// Mean reversion - pull price back toward base price
	var/price_deviation = (current_price - base_price) / base_price
	var/mean_reversion = -price_deviation * 0.02 // 2% pull back per update

	// Momentum influence (trending stocks continue trending)
	var/momentum_influence = momentum * 0.08
	momentum += (base_change * 0.05) // Reduced momentum accumulation
	momentum *= 0.95 // Stronger momentum decay

	// Combine all factors
	var/total_change = (base_change + sector_influence + sentiment_influence + momentum_influence + mean_reversion) / 100.0

	// Apply sector volatility multiplier
	total_change *= sector_data.volatility

	// Update price
	var/new_price = current_price * (1 + total_change)
	new_price = max(base_price * 0.1, new_price) // Prevent price from going below 10% of base

	current_price = round(new_price, 0.01)
	price_history += current_price

	// Trim history
	if(price_history.len > PRICE_HISTORY_LENGTH)
		price_history.Cut(1, 2)

/datum/stock/proc/get_price_change_percent()
	if(price_history.len < 2)
		return 0

	var/old_price = price_history[max(1, price_history.len - 90)] // 15 minutes ago (90 * 10 seconds)
	return round(((current_price - old_price) / old_price) * 100, 0.01)

/datum/stock/proc/get_recent_change_percent()
	if(price_history.len < 2)
		return 0

	var/previous_price = price_history[price_history.len - 1]
	return round(((current_price - previous_price) / previous_price) * 100, 0.01)

// Modified buy_shares proc to track purchase prices
/datum/stock/proc/buy_shares(ckey, amount)
	if(!ckey || amount <= 0)
		return FALSE

	if(amount > available_shares)
		return FALSE

	var/total_cost = amount * current_price
	var/datum/vtm_bank_account/account = get_bank_account(ckey)

	if(!account || account.balance < total_cost)
		return FALSE

	// Deduct money
	account.balance -= total_cost

	// Update shares
	if(!(ckey in shareholders))
		shareholders[ckey] = 0
	shareholders[ckey] += amount
	available_shares -= amount

	// Track purchase data for P&L calculation
	if(!(ckey in shareholder_purchase_data))
		shareholder_purchase_data[ckey] = list("total_shares" = 0, "total_cost" = 0)

	shareholder_purchase_data[ckey]["total_shares"] += amount
	shareholder_purchase_data[ckey]["total_cost"] += total_cost

	return TRUE

// Modified sell_shares proc to update purchase tracking
/datum/stock/proc/sell_shares(ckey, amount)
	if(!ckey || amount <= 0)
		return FALSE

	if(!(ckey in shareholders) || shareholders[ckey] < amount)
		return FALSE

	var/total_value = amount * current_price
	var/datum/vtm_bank_account/account = get_bank_account(ckey)

	if(!account)
		return FALSE

	// Add money
	account.balance += total_value

	// Update shares
	shareholders[ckey] -= amount
	if(shareholders[ckey] <= 0)
		shareholders -= ckey
	available_shares += amount

	// Update purchase data proportionally
	if(ckey in shareholder_purchase_data && shareholders[ckey] > 0)
		var/remaining_shares = shareholders[ckey]
		var/total_shares = shareholder_purchase_data[ckey]["total_shares"]
		var/proportion_remaining = remaining_shares / total_shares

		shareholder_purchase_data[ckey]["total_shares"] = remaining_shares
		shareholder_purchase_data[ckey]["total_cost"] *= proportion_remaining
	else if(!(ckey in shareholders))
		// Sold all shares, clear purchase data
		shareholder_purchase_data -= ckey

	return TRUE

// New proc to get average purchase price
/datum/stock/proc/get_average_purchase_price(ckey)
	if(!(ckey in shareholder_purchase_data))
		return 0

	var/total_shares = shareholder_purchase_data[ckey]["total_shares"]
	var/total_cost = shareholder_purchase_data[ckey]["total_cost"]

	if(total_shares <= 0)
		return 0

	return round(total_cost / total_shares, 0.01)

// New proc to get holdings P&L percentage
/datum/stock/proc/get_holdings_pnl_percent(ckey)
	var/purchase_price = get_average_purchase_price(ckey)
	if(purchase_price <= 0)
		return 0

	return round(((current_price - purchase_price) / purchase_price) * 100, 0.01)

/datum/stock/proc/get_shares_owned(ckey)
	if(ckey in shareholders)
		return shareholders[ckey]
	return 0

// =============================================================================
// UTILITY PROCEDURES
// =============================================================================

/proc/get_bank_account(ckey)
	// Find bank account by character name
	// This integrates with your existing bank system
	for(var/datum/vtm_bank_account/account in GLOB.bank_account_list)
		if(account.account_owner == ckey)
			return account
	return null

// Global market instance
GLOBAL_DATUM_INIT(stock_market, /datum/stock_market, new)
