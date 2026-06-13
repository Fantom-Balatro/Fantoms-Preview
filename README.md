Removed the 5-second calculation delay File: CorePreview.lua, InitPreview.lua
The original mod wrapped FN.SIM.run() in a coroutine with an artificial 5-second wait. Since the simulation is fully deterministic and needs only one call, the coroutine and all related state (lock_updates, five_second_coroutine) were removed entirely. Score now calculates instantly.

Auto-calculate mode (button becomes a toggle) Files: InitPreview.lua, InterfacePreview.lua, CorePreview.lua
Added auto_calculate = true to FN.PRE state (defaults on at startup) The "Calculate Score" button now toggles auto-calculate on/off instead of triggering a one-shot calculation When on: score updates live whenever cards are selected/deselected When off: score display clears
Button color reflects state: red = on, grey = off (via calculate_score_button_UI_set per-frame func)
3. Button text and size improvements File: InterfacePreview.lua

Button text changed to " Autocalculate Score "
Button made slightly larger: minh=0.55, padding=0.12, text scale=0.4
4. Fixed Plasma Deck + The Hook causing a 5–20 second hang File: EngineSimulate.lua

Root cause: simulate_deck_effects() (Plasma Deck) and simulate_blind_effects() (The Flint) were calling the global mod_chips/mod_mult functions, which are patched by Steamodded to trigger UI/scoring events. With The Hook blind generating up to 29 card-discard combos × 3 runs (min/exact/max), this caused ~87 unintended side-effect calls per preview.

Fix: replaced all calls with FN.SIM.mod_chips() and FN.SIM.mod_mult() — the side-effect-free simulation versions.

E-notation threshold matches vanilla Balatro File: UtilsPreview.lua
The mod was switching to e-notation at 1e7. Changed to use G.E_SWITCH_POINT or 1e11, which matches vanilla Balatro's threshold (~100 billion).

Warning color when score won't beat the blind File: CorePreview.lua
Added salmon/pink-red coloring (G.C.HAND_LEVELS[6], #f87d75) in two cases:

Range display (X - Y): the min (left) number turns salmon if it won't beat the blind Single number display: turns salmon if it's the last hand and even the max estimate won't beat the blind The existing gold color (G.C.MONEY) for winning scores is preserved; salmon only appears as a warning.

Score display hidden outside hand-playing states File: CorePreview.lua
Added an early-return guard in fn_pre_score_UI_set that clears the score text (sets it to a single space to prevent UI compression) when the game is not in one of: SELECTING_HAND, DRAW_TO_HAND, PLAY_TAROT, or HAND_PLAYED. This prevents the score from showing stale numbers on the cash-out screen and other non-game screens.
