--- Original: Divvy's Preview for Balatro - Init.lua
--
-- Global values that must be present for the rest of this mod to work.

if not FN then FN = {} end

FN.PRE = {
   data = {
      score = {min = 0, exact = 0, max = 0},
      dollars = {min = 0, exact = 0, max = 0}
   },
   text = {
      score = {l = "", r = ""},
      dollars = {top = "", bot = ""}
   },
   joker_order = {},
   hand_order = {}
}

FN.PRE._start_up = Game.start_up
function Game:start_up()
   FN.PRE._start_up(self)

   if not G.SETTINGS.FN then G.SETTINGS.FN = {} end
   if not G.SETTINGS.FN.PRE then
      G.SETTINGS.FN.PRE = true

      G.SETTINGS.FN.preview_score = true
      G.SETTINGS.FN.preview_dollars = true
      G.SETTINGS.FN.hide_face_down = true
      G.SETTINGS.FN.show_min_max = true
   end

end
