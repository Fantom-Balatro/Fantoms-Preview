local DVSJ = DV.SIM.JOKERS

DVSJ.simulate_doublerainbow = function(j, context)
   if context.cardarea == G.play and context.repetition then
      if context.other_card.ability.name == "Lucky Card" then
         DV.SIM.add_reps(1)
      end
   end
   -- TODO: The source also has G.hand cardarea predicated on context.card_effects.
   -- I'm unsure of what it does, and currently not mirroring here.
end
DVSJ.simulate_starfruit = function(j, context)
   -- TODO: Verify
   if context.cardarea == G.jokers and context.before then
      if G.GAME.current_round.hands_played == 0 then
         local hand_data = G.GAME.hands[DV.SIM.env.scoring_name]
         
         local rand = pseudorandom("star") -- Must reuse same pseudorandom value:
         local exact_chips, min_chips, max_chips = DV.SIM.get_probabilistic_extremes(rand, j.ability.extra, hand_data.l_chips, 0)
         local exact_mult,  min_mult,  max_mult  = DV.SIM.get_probabilistic_extremes(rand, j.ability.extra, hand_data.l_mult,  0)
         
         DV.SIM.add_chips(exact_chips, min_chips, max_chips)
         DV.SIM.add_mult(exact_mult, min_mult, max_mult)
      end
   end
end

local function level_diff()
   local num_hands = 0
   local num_levels = 0
   for _, hand in ipairs(G.GAME.hands) do
      num_hands = num_hands + 1
      num_levels = num_levels + hand.level
   end
   return (num_levels - num_hands)
end
DVSJ.simulate_eclipse = function(j, context)
   -- TODO: Verify
   if context.cardarea == G.jokers and context.global then
      local lvl_diff = level_diff()
      if lvl_diff > 0 then
         DV.SIM.add_chips(lvl_diff)
      end
   end
end

DVSJ.simulate_rubberducky = function(j, context)
end
