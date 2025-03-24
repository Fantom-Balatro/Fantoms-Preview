local DVSJ = DV.SIM.JOKERS

DVSJ.simulate_badlegaldefence = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_basepaul_card = function(j, context)
   if context.cardarea == G.jokers and context.gloabl then
      DV.SIM.x_mult(j.ability.extra.x_mult)
      if string.find(string.lower(G.PROFILES[G.SETTINGS.profile].name), "paul") then
         DV.SIM.x_mult(10)
      end
   end
end
DVSJ.simulate_bladedance = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_blasphemy = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(j.ability.extra.xmult)
   end
end
DVSJ.simulate_bloodpact = function(j, context)
   if context.cardarea == G.jokers and context.global then
      local any_heart = false
      for _, card in ipairs(context.full_hand) do
         if DV.SIM.is_suit(card, "Hearts") then
            any_heart = true
            break
         end
      end
      if not any_heart then
         DV.SIM.x_mult(j.ability.extra)
      end
   end
end
DVSJ.simulate_bowlingball = function(j, context)
   if context.cardarea == G.play and context.individual then
      if DV.SIM.is_rank(context.other_card, 3) then
         DV.SIM.add_chips(j.ability.extra.chips)
         DV.SIM.add_mult(j.ability.extra.mult)
      end
   end
end
DVSJ.simulate_cba = function(j, context)
   -- TODO: Unsure how the mod's implementation works?
end
DVSJ.simulate_clipart = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_clownfish = function(j, context)
   if context.cardarea == G.play and context.individual then
      if context.other_card.ability.name ~= "Default Base" then
         DV.SIM.add_chips(j.ability.extra.chips)
         DV.SIM.add_mult(j.ability.extra.mult)
      end
   end
end
DVSJ.simulate_colorem = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_coupon_catalogue = function(j, context)
   if context.cardarea == G.jokers and context.global then
      local redeemed = 0
      for _, v in pairs(G.GAME.used_vouchers) do
         if v then redeemed = redeemed + 1 end
      end
      DV.SIM.add_mult(j.ability.extra.mult * redeemed)
   end
end
DVSJ.simulate_css = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_dramaticentrance = function(j, context)
   if context.cardarea == G.jokers and context.global then
      if G.GAME.current_round.hands_played == 0 then
         DV.SIM.add_chips(j.ability.extra.chips)
      end
   end
end
DVSJ.simulate_dropkick = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_expansion_pack = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_fleshpanopticon = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_fleshprison = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_globe = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_goldencarrot = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_hallofmirrors = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_hollow = function(j, context)
   if context.cardarea == G.jokers and context.global then
      if G.hand.config.card_limit < j.ability.extra.thresh then
         local diff = j.ability.extra.thresh - G.hand.config.card_limit
         DV.SIM.add_mult(j.ability.extra.mult_per * diff)
      end
   end
end
DVSJ.simulate_hugejoker = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(j.ability.extra.x_mult)
   end
end
DVSJ.simulate_hyperbeam = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(j.ability.extra)
   end
end
DVSJ.simulate_impostor = function(j, context)
   if context.cardarea == G.jokers and context.global then
      local num_reds = 0
      for _, card in ipairs(context.full_hand) do
         if DV.SIM.is_suit(card, "Hearts") or DV.SIM.is_suit(card, "Diamonds") then
            num_reds = num_reds + 1
         end
      end
      if num_reds == 1 then
         DV.SIM.x_mult(j.ability.extra.x_mult)
      end
   end
end
DVSJ.simulate_jankman = function(j, context)
   if context.cardarea == G.jokers and context.other_joker then
      local is_vanilla = false
      for _, j in ipairs(MF_VANILLA_JOKERS) do
         if j == context.other_joker.config.center.key then
            is_vanilla = true
            break
         end
      end
      if not is_vanilla then
         DV.SIM.x_mult(j.ability.extra.x_mult)
      end
   end
end
DVSJ.simulate_jester = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_chips(j.ability.extra.chips)
   end
end
DVSJ.simulate_loadeddisk = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_lollipop = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(j.ability.x_mult)
   end
end
DVSJ.simulate_luckycharm = function(j, context)
   if context.cardarea == G.jokers and context.global then
      local exact_mult, min_mult, max_mult = DV.SIM.get_probabilistic_extremes(pseudorandom("lucky_charm_mult"), j.ability.extra.mult_chance, j.ability.extra.mult, 0)
      DV.SIM.add_mult(exact_mult, min_mult, max_mult)
   end
end
DVSJ.simulate_mashupalbum = function(j, context)
   if context.cardarea == G.jokers and context.before then
      if next(context.poker_hands["Flush"]) then
         local card1 = context.scoring_hand[1]
         if DV.SIM.is_suit(card1, "Hearts") or DV.SIM.is_suit(card1, "Diamonds") then
            j.ability.extra.mult = j.ability.extra.mult + 4
         else
            j.ability.extra.chips = j.ability.extra.chips + 15
         end
      end
   end
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_chips(j.ability.extra.chips)
      DV.SIM.add_mult(j.ability.extra.mult)
   end
end
DVSJ.simulate_monochrome = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.add_mult(j.ability.extra.mult)
   end
end
DVSJ.simulate_mspaint = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_philosophical = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_pixeljoker = function(j, context)
   if context.cardarea == G.play and context.individual then
      if DV.SIM.is_rank(context.other_card, {4, 9, 14}) then
         DV.SIM.x_mult(j.ability.extra.x_mult)
      end
   end
end
DVSJ.simulate_rainbow = function(j, context)
   -- TODO: Unsure how to implement currently
end
DVSJ.simulate_recycling = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_rosetinted = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_simplified = function(j, context)
   if context.cardarea == G.jokers and context.other_joker then
      if context.other_joker.rarity == 1 then
         DV.SIM.add_mult(j.ability.extra.mult)
      end
   end
end
DVSJ.simulate_spiral = function(j, context)
   if context.cardarea == G.jokers and context.global then
      local jdata = j.ability.extra
      local jmult = jdata.mult + math.floor(jdata.coeff * math.cos(math.pi/jdata.dilation * G.GAME.dollars or 0) + 0.5)
      DV.SIM.add_mult(jmult)
   end
end
DVSJ.simulate_stylemeter = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_teacup = function(j, context)
   if context.cardarea == G.jokers and context.before then
      local hand_data = G.GAME.hands[DV.SIM.env.scoring_name]
      DV.SIM.add_chips(hand_data.l_chips)
      DV.SIM.add_mult(hand_data.l_mult)
   end
end
DVSJ.simulate_the_solo = function(j, context)
   if context.cardarea == G.jokers and context.before then
      if #context.full_hand == 1 then
         j.ability.extra.x_mult = j.ability.extra.x_mult + j.ability.extra.x_mult_gain
      end
   elseif context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(j.ability.extra.x_mult)
   end
end
DVSJ.simulate_tonersoup = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_treasuremap = function(j, context)
   -- Effect not relevant
end
DVSJ.simulate_triangle = function(j, context)
   if context.cardarea == G.play and context.individual then
      -- vs. next(context.poker_hands["Three of a Kind"]) ?
      if context.scoring_name == "Three of a Kind" then
         DV.SIM.x_mult(j.ability.extra.x_mult)
      end
   end
end
DVSJ.simulate_virtual = function(j, context)
   if context.cardarea == G.jokers and context.global then
      DV.SIM.x_mult(j.ability.extra)
   end
end

local MF_VANILLA_JOKERS = {"j_joker", "j_greedy_joker", "j_lusty_joker", "j_wrathful_joker", "j_gluttenous_joker", "j_zany", "j_mad", "j_crazy", "j_droll", "j_sly", "j_wily", "j_clever", "j_devious", "j_crafty", "j_half", "j_stencil", "j_four_fingers", "j_mime", "j_credit_card", "j_ceremonial", "j_banner", "j_mystic_summit", "j_marble", "j_loyalty_card", "j_8_ball", "j_misprint", "j_dusk", "j_raised_fist", "j_chaos", "j_fibonacci", "j_steel_joker", "j_scary_face", "j_abstract", "j_delayed_grat", "j_hack", "j_pareidolia", "j_gros_michel", "j_even_steven", "j_odd_todd", "j_scholar", "j_business", "j_supernova", "j_ride_the_bus", "j_space", "j_egg", "j_burglar", "j_blackboard", "j_runner", "j_ice_cream", "j_dna", "j_splash", "j_blue_joker", "j_sixth_sense", "j_constellation", "j_hiker", "j_faceless", "j_green_joker", "j_superposition", "j_todo_list", "j_cavendish", "j_card_sharp", "j_red_card", "j_madness", "j_square", "j_seance", "j_riff_raff", "j_vampire", "j_shortcut", "j_hologram", "j_vagabond", "j_baron", "j_cloud_9", "j_rocket", "j_obelisk", "j_midas_mask", "j_luchador", "j_photograph", "j_gift", "j_turtle_bean", "j_erosion", "j_reserved_parking", "j_mail", "j_to_the_moon", "j_hallucination", "j_fortune_teller", "j_juggler", "j_drunkard", "j_stone", "j_golden", "j_lucky_cat", "j_baseball", "j_bull", "j_diet_cola", "j_trading", "j_flash", "j_popcorn", "j_trousers", "j_ancient", "j_ramen", "j_walkie_talkie", "j_selzer", "j_castle", "j_smiley", "j_campfire", "j_ticket", "j_mr_bones", "j_acrobat", "j_sock_and_buskin", "j_swashbuckler", "j_troubadour", "j_certificate", "j_smeared", "j_throwback", "j_hanging_chad", "j_rough_gem", "j_bloodstone", "j_arrowhead", "j_onyx_agate", "j_glass", "j_ring_master", "j_flower_pot", "j_blueprint", "j_wee", "j_merry_andy", "j_oops", "j_idol", "j_seeing_double", "j_matador", "j_hit_the_road", "j_duo", "j_trio", "j_family", "j_order", "j_tribe", "j_stuntman", "j_invisible", "j_brainstorm", "j_satellite", "j_shoot_the_moon", "j_drivers_license", "j_cartomancer", "j_astronomer", "j_burnt", "j_bootstraps", "j_caino", "j_triboulet", "j_yorick", "j_chicot", "j_perkeo"}
