
-- Consts for Sorting, shortcuts for common cases
local CDG_SORT_DESCENDING = function(scores, playera, playerb) return scores[playerb] < scores[playera] end
local CDG_SORT_ASCENDING  = function(scores, playera, playerb) return scores[playerb] > scores[playera] end
local CDG_MAX_ROLL = function(roll) return (tonumber(roll) > 1000000) and 1000000 or tonumber(roll) end

-- High/Low 
-- ==================
CDG_HILO = {
	-- String for game name
	label = "HiLo",
	
	init_game = function(game)
		game.data.roll_lower = 1
		game.data.roll_upper = CDG_MAX_ROLL(game.data.gold_amount)
		game.data.roll_range = "(1-"..game.data.roll_upper..")"
	end,
	
	roll_to_score = function(roll)
		return tonumber(roll)
	end,
	
	fmt_score = function(roll) return roll end,

	sort_rolls = CDG_SORT_DESCENDING,
	
	payout = function(game)
		game.data.cash_winnings = game.data.winning_roll - game.data.losing_roll
	end,
}

-- BigTwos 
-- ==============
CDG_BIGTWOS = {
	label = "BigTwos",
	
	init_game = function(game)
		game.data.roll_lower = 1
		game.data.roll_upper = 2
		game.data.roll_range = "(1-2)"
	end,
	
	roll_to_score = function(roll)
		return tonumber(roll)
	end,
	
	fmt_score = function(roll) return roll end,
	
	sort_rolls = CDG_SORT_DESCENDING,
	
	payout = function(game)
		game.data.cash_winnings = game.data.gold_amount
	end,

}

-- Inverse
-- ===========
CDG_INVERSE = {
	label = "Inverse",
	
	init_game = function(game)
		game.data.roll_lower = 1
		game.data.roll_upper = CDG_MAX_ROLL(game.data.gold_amount)
		game.data.roll_range = "(1-"..game.data.roll_upper..")"
	end,
	
	roll_to_score = function(roll)
		return tonumber(roll)
	end,
	
	fmt_score = function(roll) return roll end,
	
	sort_rolls = CDG_SORT_ASCENDING,
	
	payout = function(game)
		game.data.cash_winnings = game.data.losing_roll - game.data.winning_roll
	end,

}

-- Russian Roullette
-- ===================
CDG_ROULETTE= {
	label = "Roullette",
	
	init_game = function(game)
		game.data.roll_lower = 1
		game.data.roll_upper = 6
		game.data.roll_range = "(1-6)"
	end,
	
	roll_to_score = function(roll)
		if (tonumber(roll) == 1) then
			return 0 -- They LOSE
		else
			return 1
		end
	end,
	
	fmt_score = function(roll) return roll end,
	
	sort_rolls = CDG_SORT_DESCENDING,
	
	payout = function(game)
		game.data.cash_winnings = game.data.gold_amount
	end,

}


-- Yahtzee
-- ============
local function ScoreYahtzee(roll)
	-- Get the total of this dice, common score
	total = 0
	for digit in string.gmatch(roll, "%d") do
		if (tonumber(digit) == 0) then
			total = total + 1 -- Adjust for 0
		else
			total = total + tonumber(digit)
		end
	end
	
	hand, score, highroll = "", 0, 0
	
	-- Evaluate best possible hand
	for digit in string.gmatch(roll, "%d") do
	
		-- If you hit these your other numbers wont be better
		local _, count = string.gsub(roll, digit, "")
		if (count == 5) then
			return "YAHTZEE!", 50 + total
		end
		
		if (count == 4) then
			return "Four of a Kind!", 40 + total
		end
		
		if (count == 3) then
			-- Check for Full House
			for digit in string.gmatch(roll, "%d") do
				local _, other_count = string.gsub(roll, digit, "")
				if (other_count == 2) then
					return "Full House!", 35 + total
				end
			end
			
			return "Three of a Kind!", 30 + total
		end
		
		
		-- Doubles, could get better
		if (count == 2) then
			-- Check for full house
			for digit in string.gmatch(roll, "%d") do
				local _, other_count = string.gsub(roll, digit, "")
				if (other_count == 3) then
					return "Full House!", 35 + total
				end
			end
			
			-- Doubles are the dice added together, 0->1 
			new_score = tonumber(digit)*2 + total
			if (tonumber(digit) == 0) then
				new_score = 2 + total
			end
			
			-- Evaluate the best doubles
			if (new_score > score) then
				score = new_score 
				hand = "Double "..digit.."s!"
			end
		end
		
		-- Singles UGH
		if (count == 1) then
			if (tonumber(digit) > highroll) then
				highroll = tonumber(digit)
			end
		end
		
	end	
	
	-- Singles Bummer
	if (score == 0) then
		score = highroll
		hand = "Singles, "..highroll.." High"
		if (highroll == 0) then
			score = 1
		end
	end

	return hand, score
end

local function FormatYahtzee(roll)
	local ret_string = ""
	for digit in string.gmatch(roll, "%d") do
		ret_string = ret_string..digit.."-"
    end
	ret_string = ret_string.."!!"
	return string.gsub(ret_string, "-!!", "")
end


CDG_YAHTZEE = {
	label = "Yahtzee",
	
	init_game = function(game)
		game.data.roll_range = "(11111-99999)"
		game.data.roll_upper = 99999
		game.data.roll_lower = 11111
	end,
	
	roll_to_score = function(roll)
		hand, score = ScoreYahtzee(roll)
		return score
	end,
	
	fmt_score = function(roll)
		hand, score = ScoreYahtzee(roll)
		return " "..score.." - "..hand
	end,
	
	sort_rolls =  function(scores, playera, playerb) 
		local _, scoreA = ScoreYahtzee(scores[playera])
		local _, scoreB = ScoreYahtzee(scores[playerb])
		-- Sort from Highest to Lowest
		return scoreB < scoreA
	end,
	
	payout = function(game)
		for player, roll in CalmDownandGamble:sortedpairs(game.data.player_rolls, game.mode.sort_rolls) do
			local hand, score = ScoreYahtzee(roll)
			CalmDownandGamble:MessageChat(player.." Roll: "..FormatYahtzee(roll).." Score: "..score.." - "..hand)
		end
		game.data.cash_winnings = game.data.gold_amount
	end,

}
