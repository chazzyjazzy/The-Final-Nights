// =============================================================================
// ENHANCED STOCK TRADING COMPUTER
// =============================================================================

/obj/machinery/computer/stockexchange
	name = "stock trading terminal"
	desc = "A professional trading workstation running advanced market analysis software. The gateway to Wall Street profits and devastating losses."
	icon = 'icons/obj/computer.dmi'
	icon_state = "oldcomp"
	icon_screen = "stock_computer"
	icon_keyboard = "no_keyboard"

	var/logged_in_ckey = ""
	var/datum/vtm_bank_account/current_account = null
	var/datum/browser/current_popup = null
	var/is_active = FALSE

	interaction_flags_atom = INTERACT_ATOM_REQUIRES_DEXTERITY | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_REQUIRES_ANCHORED
	light_color = "#FFD700"

/obj/machinery/computer/stockexchange/Initialize()
	. = ..()
	// Register with market for updates
	if(GLOB.stock_market)
		GLOB.stock_market.register_terminal(src)

/obj/machinery/computer/stockexchange/Destroy()
	if(GLOB.stock_market)
		GLOB.stock_market.unregister_terminal(src)
	if(current_popup)
		current_popup.close()
	return ..()

/obj/machinery/computer/stockexchange/ui_interact(mob/user)
	. = ..()

	// Auto-login system
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		logged_in_ckey = H.real_name
		current_account = get_bank_account(logged_in_ckey)

	is_active = TRUE
	display_stock_interface(user)

/obj/machinery/computer/stockexchange/proc/display_stock_interface(mob/user)
	var/css = {"<style>
		body {
			font-family: 'Segoe UI', 'Arial', sans-serif;
			background: linear-gradient(135deg, #2c2416 0%, #1a1611 100%);
			color: #d4af37;
			margin: 0;
			padding: 10px;
		}
		.header {
			text-align: center;
			border-bottom: 2px solid #d4af37;
			padding-bottom: 10px;
			margin-bottom: 15px;
			background: rgba(212, 175, 55, 0.1);
			border-radius: 5px;
			padding: 15px;
		}
		.balance {
			text-align: center;
			font-size: 18px;
			font-weight: bold;
			margin-bottom: 15px;
			background: rgba(0, 0, 0, 0.3);
			padding: 10px;
			border-radius: 5px;
		}
		.market-index {
			text-align: center;
			font-size: 16px;
			margin-bottom: 20px;
			padding: 15px;
			border: 1px solid #d4af37;
			background: rgba(212, 175, 55, 0.05);
			border-radius: 5px;
		}
		.stock-table {
			width: 100%;
			border-collapse: collapse;
			margin-bottom: 20px;
			background: rgba(0, 0, 0, 0.2);
			border-radius: 5px;
			overflow: hidden;
		}
		.stock-table th {
			background: linear-gradient(135deg, #8b7355 0%, #5d4e37 100%);
			color: #ffffff;
			padding: 12px 8px;
			border: 1px solid #d4af37;
			text-align: center;
			font-weight: bold;
		}
		.stock-table td {
			padding: 8px 6px;
			border: 1px solid #8b7355;
			text-align: center;
			background: rgba(212, 175, 55, 0.02);
		}
		.stock-table tr:nth-child(even) {
			background: rgba(139, 115, 85, 0.1);
		}
		.stock-table tr:hover {
			background: rgba(212, 175, 55, 0.1);
		}
		.positive { color: #22c55e; font-weight: bold; }
		.negative { color: #ef4444; font-weight: bold; }
		.stock-name {
			color: #f4e4bc;
			cursor: pointer;
			text-decoration: underline;
			font-weight: bold;
		}
		.ticker {
			color: #ffffff;
			font-weight: bold;
			font-family: 'Courier New', monospace;
		}
		.btn {
			background: linear-gradient(135deg, #8b7355 0%, #5d4e37 100%);
			color: #ffffff;
			border: 1px solid #d4af37;
			padding: 6px 12px;
			margin: 2px;
			cursor: pointer;
			text-decoration: none;
			font-size: 11px;
			border-radius: 3px;
			transition: all 0.2s;
		}
		.btn:hover {
			background: linear-gradient(135deg, #d4af37 0%, #b8941f 100%);
			color: #000000;
		}
		.btn-buy {
			border-color: #22c55e;
			background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
		}
		.btn-buy:hover {
			background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
		}
		.btn-sell {
			border-color: #ef4444;
			background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
		}
		.btn-sell:hover {
			background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
		}
		.sector-header {
			background: linear-gradient(135deg, #5d4e37 0%, #3d2f1f 100%);
			color: #f4e4bc;
			font-weight: bold;
			text-align: left;
			padding: 10px;
			border-top: 2px solid #d4af37;
		}
		.auto-refresh {
			text-align: center;
			font-size: 12px;
			color: #8b7355;
			margin-top: 15px;
			font-style: italic;
		}
	</style>"}

	var/market_change = 0
	if(GLOB.stock_market?.market_history.len >= 2)
		var/current_index = GLOB.stock_market.market_history[GLOB.stock_market.market_history.len]
		var/previous_index = GLOB.stock_market.market_history[max(1, GLOB.stock_market.market_history.len - 18)] // 3 minutes ago (18 * 10 seconds)
		market_change = round(((current_index - previous_index) / previous_index) * 100, 0.01)

	var/dat = "<html><head><title>Stock Trading Terminal</title>[css]</head><body>"
	dat += "<div class='header'><h2>WALL STREET EXCHANGE</h2><div style='font-size: 14px; margin-top: 5px;'>Professional Trading Platform</div></div>"

	if(current_account)
		dat += "<div class='balance'>Account Balance: $[(current_account.balance)]</div>"
	else
		dat += "<div class='balance' style='color: #ef4444;'>NO BANK ACCOUNT FOUND</div>"

	dat += "<div class='market-index'>"
	dat += "Market Index: [round(GLOB.stock_market?.market_index || 100, 0.01)] "
	dat += "<span class='[market_change >= 0 ? "positive" : "negative"]'>"
	dat += "[market_change >= 0 ? "+" : ""][market_change]%</span>"
	dat += "</div>"

	if(!GLOB.stock_market?.stocks.len)
		dat += "<div style='text-align: center; color: #ef4444;'>MARKET DATA UNAVAILABLE</div>"
	else
		dat += generate_stock_table()

	dat += "<div class='auto-refresh'>Market updates automatically every 10 seconds</div>"
	dat += "</body></html>"

	current_popup = new(user, "enhanced_stock_terminal", "Stock Trading Terminal", 900, 650)
	current_popup.set_content(dat)
	current_popup.open()

/obj/machinery/computer/stockexchange/proc/generate_stock_table()
	var/dat = "<table class='stock-table'>"
	dat += "<tr><th>Company</th><th>Ticker</th><th>Price</th><th>30min Change</th><th>Owned</th><th>Holdings P&L</th><th>Actions</th></tr>"

	// Group stocks by sector
	var/list/sectors_used = list()
	for(var/datum/enhanced_stock/stock in GLOB.stock_market.stocks)
		if(!(stock.sector in sectors_used))
			sectors_used += stock.sector

	for(var/sector in sectors_used)
		// Sector header
		dat += "<tr class='sector-header'><td colspan='7'>[sector]</td></tr>"

		// Stocks in this sector
		for(var/datum/enhanced_stock/stock in GLOB.stock_market.stocks)
			if(stock.sector != sector)
				continue

			var/price_change = stock.get_price_change_percent()
			var/owned_shares = stock.get_shares_owned(logged_in_ckey)
			var/holdings_change = "N/A"

			// Calculate holdings P&L based on purchase price vs current price
			if(owned_shares > 0)
				var/pnl_percent = stock.get_holdings_pnl_percent(logged_in_ckey)
				if(pnl_percent != 0)
					holdings_change = "[pnl_percent >= 0 ? "+" : ""][pnl_percent]%"
				else
					holdings_change = "HELD"

			dat += "<tr>"
			dat += "<td><a href='byond://?src=[REF(src)];chart=[stock.ticker]' class='stock-name'>[stock.name]</a></td>"
			dat += "<td class='ticker'>[stock.ticker]</td>"
			dat += "<td>$[stock.current_price]</td>"
			dat += "<td class='[price_change >= 0 ? "positive" : "negative"]'>[price_change >= 0 ? "+" : ""][price_change]%</td>"
			dat += "<td>[(owned_shares)]</td>"
			dat += "<td class='[owned_shares > 0 ? (holdings_change != "N/A" && holdings_change != "HELD" ? (text2num(replacetext(holdings_change, "%", "")) >= 0 ? "positive" : "negative") : "") : ""]'>[holdings_change]</td>"
			dat += "<td>"
			dat += "<a href='byond://?src=[REF(src)];buy=[stock.ticker]' class='btn btn-buy'>BUY</a>"
			if(owned_shares > 0)
				dat += "<a href='byond://?src=[REF(src)];sell=[stock.ticker]' class='btn btn-sell'>SELL</a>"
			dat += "</td>"
			dat += "</tr>"

	dat += "</table>"
	return dat


/obj/machinery/computer/stockexchange/proc/refresh_display()
	if(!is_active || !current_popup)
		return

	// Find the user who has this terminal open
	var/mob/user = null
	for(var/mob/M in range(2, src))
		if(M.client)
			user = M
			break

	if(user)
		display_stock_interface(user)

/obj/machinery/computer/stockexchange/Topic(href, href_list)
	if(..())
		return 1

	if(!usr || (!(usr in range(1, src)) && iscarbon(usr)))
		return 1

	if(href_list["buy"])
		handle_buy_order(href_list["buy"], usr)

	if(href_list["sell"])
		handle_sell_order(href_list["sell"], usr)

	if(href_list["chart"])
		show_stock_chart(href_list["chart"], usr)

	src.add_fingerprint(usr)
	// Don't call updateUsrDialog() as we handle updates automatically

/obj/machinery/computer/stockexchange/proc/handle_buy_order(ticker, mob/user)
	if(!current_account)
		to_chat(user, "<span class='danger'>No bank account detected!</span>")
		return

	var/datum/enhanced_stock/stock = GLOB.stock_market.get_stock_by_ticker(ticker)
	if(!stock)
		to_chat(user, "<span class='danger'>Stock not found!</span>")
		return

	var/max_affordable = round(current_account.balance / stock.current_price)
	var/max_available = min(max_affordable, stock.available_shares)

	if(max_available <= 0)
		to_chat(user, "<span class='danger'>Cannot afford any shares or none available!</span>")
		return

	var/amount = input(user, "How many shares of [stock.name] ([stock.ticker]) do you want to buy?\nPrice: $[stock.current_price] per share\nYou can afford: [(max_affordable)]\nAvailable: [(stock.available_shares)]", "Buy Shares", min(10, max_available)) as num|null

	if(!amount || amount <= 0)
		return

	amount = round(amount)
	amount = min(amount, max_available)

	if(stock.buy_shares(logged_in_ckey, amount))
		var/total_cost = amount * stock.current_price
		to_chat(user, "<span class='notice'>Successfully purchased [(amount)] shares of [stock.name] for $[(total_cost)]!</span>")
		display_stock_interface(user) // Refresh display after transaction
	else
		to_chat(user, "<span class='danger'>Transaction failed!</span>")

/obj/machinery/computer/stockexchange/proc/handle_sell_order(ticker, mob/user)
	if(!current_account)
		to_chat(user, "<span class='danger'>No bank account detected!</span>")
		return

	var/datum/enhanced_stock/stock = GLOB.stock_market.get_stock_by_ticker(ticker)
	if(!stock)
		to_chat(user, "<span class='danger'>Stock not found!</span>")
		return

	var/owned_shares = stock.get_shares_owned(logged_in_ckey)
	if(owned_shares <= 0)
		to_chat(user, "<span class='danger'>You don't own any shares of this stock!</span>")
		return

	var/amount = input(user, "How many shares of [stock.name] ([stock.ticker]) do you want to sell?\nPrice: $[stock.current_price] per share\nYou own: [(owned_shares)]", "Sell Shares", min(owned_shares, 10)) as num|null

	if(!amount || amount <= 0)
		return

	amount = round(amount)
	amount = min(amount, owned_shares)

	if(stock.sell_shares(logged_in_ckey, amount))
		var/total_value = amount * stock.current_price
		to_chat(user, "<span class='notice'>Successfully sold [(amount)] shares of [stock.name] for $[(total_value)]!</span>")
		display_stock_interface(user) // Refresh display after transaction
	else
		to_chat(user, "<span class='danger'>Transaction failed!</span>")

/obj/machinery/computer/stockexchange/proc/show_stock_chart(ticker, mob/user)
	var/datum/enhanced_stock/stock = GLOB.stock_market.get_stock_by_ticker(ticker)
	if(!stock)
		to_chat(user, "<span class='danger'>Stock not found!</span>")
		return

	var/chart_html = generate_price_chart(stock)
	var/datum/browser/chart_popup = new(user, "stock_chart_[ticker]", "[stock.name] ([stock.ticker]) - Price Chart", 750, 550)
	chart_popup.set_content(chart_html)
	chart_popup.open()

/obj/machinery/computer/stockexchange/proc/generate_price_chart(datum/enhanced_stock/stock)
	var/css = {"<style>
		body {
			font-family: 'Segoe UI', 'Arial', sans-serif;
			background: linear-gradient(135deg, #2c2416 0%, #1a1611 100%);
			color: #d4af37;
			margin: 10px;
		}
		.chart-header {
			text-align: center;
			margin-bottom: 20px;
			border-bottom: 1px solid #d4af37;
			padding-bottom: 15px;
			background: rgba(212, 175, 55, 0.1);
			border-radius: 5px;
			padding: 20px;
		}
		.chart-container {
			border: 2px solid #d4af37;
			background: linear-gradient(135deg, #000000 0%, #1a1611 100%);
			padding: 20px;
			text-align: center;
			border-radius: 8px;
		}
		.positive { color: #22c55e; }
		.negative { color: #ef4444; }
		.chart-line {
			width: 100%;
			height: 300px;
			border: 1px solid #8b7355;
			background: linear-gradient(135deg, #0a0a0a 0%, #1a1611 100%);
			position: relative;
			overflow: hidden;
			border-radius: 5px;
		}
		.price-point {
			position: absolute;
			width: 2px;
			background: #d4af37;
		}
	</style>"}

	var/dat = "<html><head><title>[stock.name] Chart</title>[css]</head><body>"
	dat += "<div class='chart-header'>"
	dat += "<h2>[stock.name] ([stock.ticker])</h2>"
	dat += "<p>Current Price: $[stock.current_price] | 30min Change: <span class='[stock.get_price_change_percent() >= 0 ? "positive" : "negative"]'>[stock.get_price_change_percent() >= 0 ? "+" : ""][stock.get_price_change_percent()]%</span></p>"
	dat += "</div>"

	// Generate a simple line chart using CSS
	if(stock.price_history.len >= 2)
		dat += "<div class='chart-container'>"
		dat += generate_simple_line_chart(stock)
		dat += "</div>"
	else
		dat += "<div style='text-align: center; padding: 50px;'>Insufficient data for chart</div>"

	dat += "</body></html>"
	return dat

/obj/machinery/computer/stockexchange/proc/generate_simple_line_chart(datum/enhanced_stock/stock)
	var/chart_html = "<div class='chart-line'>"

	if(stock.price_history.len < 2)
		return "<p>Not enough data for chart</p>"

	// Get min and max prices for scaling
	var/min_price = stock.price_history[1]
	var/max_price = stock.price_history[1]
	for(var/price in stock.price_history)
		if(price < min_price) min_price = price
		if(price > max_price) max_price = price

	var/price_range = max_price - min_price
	if(price_range == 0) price_range = 1 // Prevent division by zero

	// Generate price points (simplified representation)
	var/chart_width = 650
	var/chart_height = 250
	var/points_to_show = min(stock.price_history.len, 60) // Show last 60 data points
	var/start_idx = max(1, stock.price_history.len - points_to_show + 1)

	chart_html += "<svg width='650' height='250' style='border: 1px solid #8b7355;'>"

	// Draw grid lines
	for(var/i = 0; i <= 5; i++)
		var/y = (i * chart_height / 5)
		chart_html += "<line x1='0' y1='[y]' x2='[chart_width]' y2='[y]' stroke='#5d4e37' stroke-width='1'/>"

	// Draw price line
	var/path = "M "
	for(var/i = start_idx; i <= stock.price_history.len; i++)
		var/price = stock.price_history[i]
		var/x = ((i - start_idx) * chart_width / (points_to_show - 1))
		var/y = chart_height - ((price - min_price) / price_range * chart_height)

		if(i == start_idx)
			path += "[x],[y] "
		else
			path += "L [x],[y] "

	chart_html += "<path d='[path]' stroke='#d4af37' stroke-width='2' fill='none'/>"

	// Add price labels
	chart_html += "<text x='10' y='20' fill='#d4af37' font-size='12'>$[max_price]</text>"
	chart_html += "<text x='10' y='[chart_height - 10]' fill='#d4af37' font-size='12'>$[min_price]</text>"

	chart_html += "</svg>"
	chart_html += "</div>"

	return chart_html
