DVSJ.simulate_mp_defensive_joker= function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_chips(joker_obj.ability.t_chips)
   end
end

DVSJ.simulate_mp_taxes = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_mult(joker_obj.ability.extra.mult)
   end
end

DVSJ.simulate_mp_pacifist = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global and not MP.is_pvp_boss() then
      DV.SIM.x_mult(joker_obj.ability.extra.x_mult)
   end
end

DVSJ.simulate_mp_conjoined_joker = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global and MP.is_pvp_boss() then
      DV.SIM.x_mult(joker_obj.ability.extra.x_mult)
   end
end

DVSJ.simulate_mp_hanging_chad = function(joker_obj, context)
   if context.cardarea == G.play and context.repetition then
      if context.other_card == context.scoring_hand[1] and not context.other_card.debuff then
         DV.SIM.add_reps(joker_obj.ability.extra)
      end
      if context.other_card == context.scoring_hand[2] and not context.other_card.debuff then
         DV.SIM.add_reps(joker_obj.ability.extra)
      end
   end
end

DVSJ.simulate_mp_lets_go_gambling = function(joker_obj, context)
   if context.cardarea == G.jokers and context.global then

      local rand = pseudorandom("gambling") -- Must reuse same pseudorandom value:
      local exact_xmult,  min_xmult, max_xmult = DV.SIM.get_probabilistic_extremes(rand, joker_obj.ability.extra.odds, joker_obj.ability.extra.xmult, 1)
      local exact_money,  min_money,  max_money  = DV.SIM.get_probabilistic_extremes(rand, joker_obj.ability.extra.odds, joker_obj.ability.extra.dollars, 0)

      DV.SIM.add_dollars(exact_money, min_money, max_money)
      DV.SIM.x_mult(exact_xmult, min_xmult, max_xmult)
   end
end