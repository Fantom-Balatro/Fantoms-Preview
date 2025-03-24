--
-- SMODS compatibility:
--

local orig_get_X_same = get_X_same
function get_X_same(num, hand)
	local clean_hand = {}
	for _, v in pairs(hand) do
		if v.get_id then
			table.insert(clean_hand, v)
		end
	end
	return orig_get_X_same(num, clean_hand)
end

local orig_get_highest = get_highest
function get_highest(hand)
    local clean_hand = {}
    for _, v in pairs(hand) do
        if v.get_nominal then
            table.insert(clean_hand, v)
        end
    end
    return orig_get_highest(clean_hand)
end
