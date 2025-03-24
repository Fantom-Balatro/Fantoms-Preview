--
-- SMODS compatibility:
--

local orig_get_X_same = get_X_same
function get_X_same(num, hand)
	return orig_get_X_same(num, clean_hand(hand))
end

local orig_get_highest = get_highest
function get_highest(hand)
	return orig_get_highest(clean_hand(hand))
end