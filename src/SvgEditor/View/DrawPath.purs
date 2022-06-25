module SvgEditor.View.DrawPath
  ( drawPath
  ) where

import Prelude
import Data.Tuple (Tuple(..))
import Data.Array (mapWithIndex)
import Effect.Aff (Aff)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import SvgEditor.PathCommand (PathCommand, commandName, points)
import SvgEditor.View.NumberInput (numberInput, Slot)

drawPath ::
  forall a.
  { editCommand :: Int -> PathCommand -> a } ->
  Array PathCommand -> HH.ComponentHTML a Slot Aff
drawPath actions pathCommands =
  HH.ul
    [ HP.class_ $ HH.ClassName "draw-path-commands" ]
    $ pathCommands
    # mapWithIndex \i pathCommand ->
        HH.li_
          [ HH.text $ commandName pathCommand
          , HH.div_ $ points pathCommand
              # mapWithIndex \j (Tuple v updateV) ->
                  let
                    key = "draw-path." <> show i <> "." <> show j

                    handleEditVec f = actions.editCommand i <<< updateV <<< f
                  in
                    HH.div_
                      [ numberInput (key <> ".x") v.x $ handleEditVec \x -> v { x = x }
                      , numberInput (key <> ".y") v.y $ handleEditVec \y -> v { y = y }
                      ]
          ]
