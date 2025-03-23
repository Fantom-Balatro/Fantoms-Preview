DVSJ.simulate_j_mp_defensive_joker= function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_chips(joker_obj.ability.extra.chips)
   end
end

DVSJ.simulate_j_mp_taxes = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_mult(joker_obj.ability.mult)
   end
end

DVSJ.simulate_j_mp_pacifist = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(joker_obj.ability.extra.Xmult)
   end
end

DVSJ.simulate_j_mp_conjoined_joker = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(joker_obj.ability.extra.Xmult)
   end
end

DVSJ.simulate_j_mp_hanging_chad = function(joker_obj, context)
   if context.cardarea == G.play and context.repetition then
      if context.other_card == context.scoring_hand[1] and not context.other_card.debuff then
         DV.SIM.add_reps(joker_obj.ability.extra)
      end
      if context.other_card == context.scoring_hand[2] and not context.other_card.debuff then
         DV.SIM.add_reps(joker_obj.ability.extra)
      end
   end
end

DVSJ.simulate_j_mp_lets_go_gambling = function(joker_obj, context)
   if context.cardarea == G.jokers and context.before then

      local rand = pseudorandom("gambling") -- Must reuse same pseudorandom value:
      local exact_xmult,  min_xmult, max_xmult = DV.SIM.get_probabilistic_extremes(rand, .25, 4, 1)
      local exact_money,  min_money,  max_money  = DV.SIM.get_probabilistic_extremes(rand, .25, 10, 0)

      DV.SIM.add_dollars(exact_money, min_money, max_money)
      DV.SIM.add_xmult(exact_xmult, min_xmult, max_xmult)
   end
end