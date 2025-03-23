--- Divvy's Simulation for Balatro - Engine.lua
--
-- The heart of this library: it replicates the game's score evaluation.

function DV.SIM.run()
   local null_ret = {score = {min=0, exact=0, max=0}, dollars = {min=0, exact=0, max=0}}
   if #G.hand.highlighted < 1 then return null_ret end

   DV.SIM.init()

   DV.SIM.manage_state("SAVE")
   DV.SIM.update_state_variables()

   if not DV.SIM.simulate_blind_debuffs() then
      DV.SIM.simulate_joker_before_effects()
      DV.SIM.add_base_chips_and_mult()
      DV.SIM.simulate_blind_effects()
      DV.SIM.simulate_scoring_cards()
      DV.SIM.simulate_held_cards()
      DV.SIM.simulate_joker_global_effects()
      DV.SIM.simulate_consumable_effects()
      DV.SIM.simulate_deck_effects()
   else -- Only Matador at this point:
      DV.SIM.simulate_all_jokers(G.jokers, {debuffed_hand = true})
   end

   DV.SIM.manage_state("RESTORE")

   return DV.SIM.get_results()
end

function DV.SIM.init()
   -- Reset:
   DV.SIM.running = {
      min   = {chips = 0, mult = 0, dollars = 0},
      exact = {chips = 0, mult = 0, dollars = 0},
      max   = {chips = 0, mult = 0, dollars = 0},
      reps = 0
   }

   -- Fetch metadata about simulated play:
   local hand_name, _, poker_hands, scoring_hand, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
   DV.SIM.env.scoring_name = hand_name

   -- Identify played cards and extract necessary data:
   DV.SIM.env.played_cards = {}
   DV.SIM.env.scoring_cards = {}
   local is_splash_joker = next(find_joker("Splash"))
   table.sort(G.hand.highlighted, function(a, b) return a.T.x < b.T.x end) -- Sorts by positional x-value to mirror card order!
   for _, card in ipairs(G.hand.highlighted) do
      local is_scoring = false
      for _, scoring_card in ipairs(scoring_hand) do
       -- Either card is scoring because it's part of the scoring hand,
       -- or there is Splash joker, or it's a Stone Card:
         if card.sort_id == scoring_card.sort_id
            or is_splash_joker
            or card.ability.effect == "Stone Card"
         then
            is_scoring = true
            break
         end
      end

      local card_data = DV.SIM.get_card_data(card)
      table.insert(DV.SIM.env.played_cards, card_data)
      if is_scoring then table.insert(DV.SIM.env.scoring_cards, card_data) end
   end

   -- Identify held cards and extract necessary data:
   DV.SIM.env.held_cards = {}
   for _, card in ipairs(G.hand.cards) do
      -- Highlighted cards are simulated as played cards:
      if not card.highlighted then
         local card_data = DV.SIM.get_card_data(card)
         table.insert(DV.SIM.env.held_cards, card_data)
      end
   end

   -- Extract necessary joker data:
   DV.SIM.env.jokers = {}
   for _, joker in ipairs(G.jokers.cards) do
      local joker_data = {
         -- P_CENTER keys for jokers have the form j_NAME, get rid of j_
         id = joker.config.center.key:sub(3, #joker.config.center.key),
         ability = copy_table(joker.ability),
         edition = copy_table(joker.edition),
         rarity = joker.config.center.rarity,
         debuff = joker.debuff
      }
      table.insert(DV.SIM.env.jokers, joker_data)
   end

   -- Extract necessary consumable data:
   DV.SIM.env.consumables = {}
   for _, consumable in ipairs(G.consumeables.cards) do
      local consumable_data = {
         -- P_CENTER keys have the form x_NAME, get rid of x_
         id = consumable.config.center.key:sub(3, #consumable.config.center.key),
         ability = copy_table(consumable.ability)
      }
      table.insert(DV.SIM.env.consumables, consumable_data)
   end

   -- Set extensible context template:
   DV.SIM.get_context = function(cardarea, args)
      local context = {
         cardarea = cardarea,
         full_hand = DV.SIM.env.played_cards,
         scoring_name = hand_name,
         scoring_hand = DV.SIM.env.scoring_cards,
         poker_hands = poker_hands
      }

      for k, v in pairs(args) do
         context[k] = v
      end

      return context
   end
end

function DV.SIM.get_card_data(card_obj)
   return {
      rank = card_obj.base.id,
      suit = card_obj.base.suit,
      base_chips = card_obj.base.nominal,
      ability = copy_table(card_obj.ability),
      edition = copy_table(card_obj.edition),
      seal = card_obj.seal,
      debuff = card_obj.debuff,
      lucky_trigger = {}
   }
end

function DV.SIM.get_results()
   local DVSR = DV.SIM.running

   local min_score   = math.floor(DVSR.min.chips   * DVSR.min.mult)
   local exact_score = math.floor(DVSR.exact.chips * DVSR.exact.mult)
   local max_score   = math.floor(DVSR.max.chips   * DVSR.max.mult)

   return {
      score   = {min = min_score,        exact = exact_score,        max = max_score},
      dollars = {min = DVSR.min.dollars, exact = DVSR.exact.dollars, max = DVSR.max.dollars}
   }
end

--
-- GAME STATE MANAGEMENT:
--

function DV.SIM.manage_state(save_or_restore)
   local DVSO = DV.SIM.orig

   if save_or_restore == "SAVE" then
      DVSO.random_data = copy_table(G.GAME.pseudorandom)
      DVSO.hand_data = copy_table(G.GAME.hands)
      return
   end

   if save_or_restore == "RESTORE" then
      G.GAME.pseudorandom = DVSO.random_data
      G.GAME.hands = DVSO.hand_data
      return
   end
end

function DV.SIM.update_state_variables()
   -- Increment poker hand played this run/round:
   local hand_info = G.GAME.hands[DV.SIM.env.scoring_name]
   hand_info.played = hand_info.played + 1
   hand_info.played_this_round = hand_info.played_this_round + 1
end

--
-- MACRO LEVEL:
--

function DV.SIM.simulate_scoring_cards()
   for _, scoring_card in ipairs(DV.SIM.env.scoring_cards) do
      DV.SIM.simulate_card_in_context(scoring_card, G.play)
   end
end

function DV.SIM.simulate_held_cards()
   for _, held_card in ipairs(DV.SIM.env.held_cards) do
      DV.SIM.simulate_card_in_context(held_card, G.hand)
   end
end

function DV.SIM.simulate_joker_global_effects()
   for _, joker in ipairs(DV.SIM.env.jokers) do
      if joker.edition then -- Foil and Holo:
         if joker.edition.chips then DV.SIM.add_chips(joker.edition.chips) end
         if joker.edition.mult  then DV.SIM.add_mult(joker.edition.mult) end
      end

      DV.SIM.simulate_joker(joker, DV.SIM.get_context(G.jokers, {global = true}))

      -- Joker-on-joker effects (eg. Blueprint):
      DV.SIM.simulate_all_jokers(G.jokers, {other_joker = joker})

      if joker.edition then -- Poly:
         if joker.edition.x_mult then DV.SIM.x_mult(joker.edition.x_mult) end
      end
   end
end

function DV.SIM.simulate_consumable_effects()
   for _, consumable in ipairs(DV.SIM.env.consumables) do
      if consumable.ability.set == "Planet" and not consumable.debuff then
         if G.GAME.used_vouchers.v_observatory and consumable.ability.consumeable.hand_type == DV.SIM.env.scoring_name then
            DV.SIM.x_mult(G.P_CENTERS.v_observatory.config.extra)
         end
      end
   end
end

function DV.SIM.add_base_chips_and_mult()
   local played_hand_data = G.GAME.hands[DV.SIM.env.scoring_name]
   DV.SIM.add_chips(played_hand_data.chips)
   DV.SIM.add_mult(played_hand_data.mult)
end

function DV.SIM.simulate_joker_before_effects()
   for _, joker in ipairs(DV.SIM.env.jokers) do
      DV.SIM.simulate_joker(joker, DV.SIM.get_context(G.jokers, {before = true}))
   end
end

function DV.SIM.simulate_blind_effects()
   if G.GAME.blind.disabled then return end

   if G.GAME.blind.name == "The Flint" then
      local function flint(data)
         local half_chips = math.floor(data.chips/2 + 0.5)
         local half_mult = math.floor(data.mult/2 + 0.5)
         data.chips = mod_chips(math.max(half_chips, 0))
         data.mult  = mod_mult(math.max(half_mult, 1))
      end

      flint(DV.SIM.running.min)
      flint(DV.SIM.running.exact)
      flint(DV.SIM.running.max)
   else
      -- Other blinds do not impact scoring; refer to Blind:modify_hand(..)
   end
end

function DV.SIM.simulate_deck_effects()
   if G.GAME.selected_back.name == 'Plasma Deck' then
      local function plasma(data)
         local sum = data.chips + data.mult
         local half_sum = math.floor(sum/2)
         data.chips = mod_chips(half_sum)
         data.mult = mod_mult(half_sum)
      end

      plasma(DV.SIM.running.min)
      plasma(DV.SIM.running.exact)
      plasma(DV.SIM.running.max)
   else
      -- Other decks do not impact scoring; refer to Back:trigger_effect(..)
   end
end

function DV.SIM.simulate_blind_debuffs()
   local blind_obj = G.GAME.blind
   if blind_obj.disabled then return false end

   -- The following are part of Blind:press_play()

   if blind_obj.name == "The Hook" then
      blind_obj.triggered = true
      for _ = 1, math.min(2, #DV.SIM.env.held_cards) do
         -- TODO: Identify cards-in-hand that can affect score, simulate with/without them for min/max
         local selected_card, card_key = pseudorandom_element(DV.SIM.env.held_cards, pseudoseed('hook'))
         table.remove(DV.SIM.env.held_cards, card_key)
         for _, joker in ipairs(DV.SIM.env.jokers) do
            -- Note that the cardarea argument is largely arbitrary (used for DV.SIM.JOKERS),
            -- I use G.hand because The Hook discards from the hand
            DV.SIM.simulate_joker(joker, DV.SIM.get_context(G.hand, {discard = true, other_card = selected_card}))
         end
      end
   end

   if blind_obj.name == "The Tooth" then
      blind_obj.triggered = true
      DV.SIM.add_dollars((-1) * #DV.SIM.env.played_cards)
   end

   -- The following are part of Blind:debuff_hand(..)

   if blind_obj.name == "The Arm" then
      blind_obj.triggered = false

      local played_hand_name = DV.SIM.env.scoring_name
      if G.GAME.hands[played_hand_name].level > 1 then
         blind_obj.triggered = true
         -- NOTE: Important to save/restore G.GAME.hands here
         -- NOTE: Implementation mirrors level_up_hand(..)
         local played_hand_data = G.GAME.hands[played_hand_name]
         played_hand_data.level = math.max(1, played_hand_data.level - 1)
         played_hand_data.mult  = math.max(1, played_hand_data.s_mult  + (played_hand_data.level-1) * played_hand_data.l_mult)
         played_hand_data.chips = math.max(0, played_hand_data.s_chips + (played_hand_data.level-1) * played_hand_data.l_chips)
      end
      return false -- IMPORTANT: Avoid duplicate effects from Blind:debuff_hand() below
   end

   if blind_obj.name == "The Ox" then
      blind_obj.triggered = false

      if DV.SIM.env.scoring_name == G.GAME.current_round.most_played_poker_hand then
         blind_obj.triggered = true
         DV.SIM.add_dollars(-G.GAME.dollars)
      end
      return false -- IMPORTANT: Avoid duplicate effects from Blind:debuff_hand() below
   end

   return blind_obj:debuff_hand(DV.SIM.env.played_cards, DV.SIM.env.poker_hands, DV.SIM.env.scoring_name, true)
end

--
-- MICRO LEVEL (CARDS):
--

function DV.SIM.simulate_card_in_context(card, cardarea)
   -- Reset and collect repetitions:
   DV.SIM.running.reps = 1
   if card.seal == "Red" then DV.SIM.add_reps(1) end
   DV.SIM.simulate_all_jokers(cardarea, {other_card = card, repetition = true})

   -- Apply effects:
   for _ = 1, DV.SIM.running.reps do
      DV.SIM.simulate_card(card, DV.SIM.get_context(cardarea, {}))
      DV.SIM.simulate_all_jokers(cardarea, {other_card = card, individual = true})
   end
end

function DV.SIM.simulate_card(card_data, context)
   -- Do nothing if debuffed:
   if card_data.debuff then return end

   if context.cardarea == G.play then
      -- Chips:
      if card_data.ability.effect == "Stone Card" then
         DV.SIM.add_chips(card_data.ability.bonus + (card_data.ability.perma_bonus or 0))
      else
         DV.SIM.add_chips(card_data.base_chips + card_data.ability.bonus + (card_data.ability.perma_bonus or 0))
      end

      -- Mult:
      if card_data.ability.effect == "Lucky Card" then
         local exact_mult, min_mult, max_mult = DV.SIM.get_probabilistic_extremes(pseudorandom("nope"), 5, card_data.ability.mult, 0)
         DV.SIM.add_mult(exact_mult, min_mult, max_mult)
         -- Careful not to overwrite `card_data.lucky_trigger` outright:
         if exact_mult > 0 then card_data.lucky_trigger.exact = true end
         if min_mult > 0 then card_data.lucky_trigger.min = true end
         if max_mult > 0 then card_data.lucky_trigger.max = true end
      else
         DV.SIM.add_mult(card_data.ability.mult)
      end

      -- XMult:
      if card_data.ability.x_mult > 1 then
         DV.SIM.x_mult(card_data.ability.x_mult)
      end

      -- Dollars:
      if card_data.seal == "Gold" then
         DV.SIM.add_dollars(3)
      end
      if card_data.ability.p_dollars > 0 then
         if card_data.ability.effect == "Lucky Card" then
            local exact_dollars, min_dollars, max_dollars = DV.SIM.get_probabilistic_extremes(pseudorandom("notthistime"), 15, card_data.ability.p_dollars, 0)
            DV.SIM.add_dollars(exact_dollars, min_dollars, max_dollars)
            -- Careful not to overwrite `card_data.lucky_trigger` outright:
            if exact_dollars > 0 then card_data.lucky_trigger.exact = true end
            if min_dollars > 0 then card_data.lucky_trigger.min = true end
            if max_dollars > 0 then card_data.lucky_trigger.max = true end
         else
            DV.SIM.add_dollars(card_data.ability.p_dollars)
         end
      end

     -- Edition:
      if card_data.edition then
         if card_data.edition.chips then DV.SIM.add_chips(card_data.edition.chips) end
         if card_data.edition.mult then DV.SIM.add_mult(card_data.edition.mult) end
         if card_data.edition.x_mult then DV.SIM.x_mult(card_data.edition.x_mult) end
      end

   elseif context.cardarea == G.hand then
      if card_data.ability.h_mult > 0 then
         DV.SIM.add_mult(card_data.ability.h_mult)
      end

      if card_data.ability.h_x_mult > 0 then
         DV.SIM.x_mult(card_data.ability.h_x_mult)
      end
   end
end

--
-- MICRO LEVEL (JOKERS):
--

function DV.SIM.simulate_all_jokers(cardarea, context_args)
   for _, joker in ipairs(DV.SIM.env.jokers) do
      DV.SIM.simulate_joker(joker, DV.SIM.get_context(cardarea, context_args))
   end
end

function DV.SIM.simulate_joker(joker_obj, context)
   -- Do nothing if debuffed:
   if joker_obj.debuff then return end

   local joker_simulation_function = DV.SIM.JOKERS["simulate_" .. joker_obj.id]
   if joker_simulation_function then joker_simulation_function(joker_obj, context) end
end
