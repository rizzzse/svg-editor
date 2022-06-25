module SvgEditor.View.LayerInfo where

import Prelude
import Effect.Aff (Aff)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import SvgEditor.Layer (Layer)
import SvgEditor.PathCommand (PathCommand)
import SvgEditor.View.DrawPath (drawPath)
import SvgEditor.View.NumberInput (numberInput, Slot)

layerInfo ::
  forall a.
  { editLayer :: (Layer -> Layer) -> a
  , deleteLayer :: a
  , editCommand :: Int -> PathCommand -> a
  } ->
  Layer -> HH.ComponentHTML a Slot Aff
layerInfo actions { name, drawPath: drawPath', fill, stroke } =
  HH.div
    [ HP.class_ $ HH.ClassName "layer-info" ]
    [ HH.input
        [ HP.value name
        , HE.onValueInput \value -> actions.editLayer _ { name = value }
        ]
    , HH.button
        [ HE.onClick \_ -> actions.deleteLayer ]
        [ HH.text "delete layer" ]
    , HH.div_
        [ HH.text "fill-color"
        , HH.input
            [ HP.value fill.color
            , HE.onValueInput \x ->
                actions.editLayer _ { fill { color = x } }
            ]
        ]
    , HH.div_
        [ HH.text "fill-opacity"
        , numberInput "layer-info.fill-opacity" fill.opacity \x ->
            actions.editLayer _ { fill { opacity = x } }
        ]
    , HH.div_
        [ HH.text "stroke-color"
        , HH.input
            [ HP.value stroke.color
            , HE.onValueInput \x ->
                actions.editLayer _ { stroke { color = x } }
            ]
        ]
    , HH.div_
        [ HH.text "stroke-opacity"
        , numberInput "layer-info.stroke-opacity" stroke.opacity \x ->
            actions.editLayer _ { stroke { opacity = x } }
        ]
    , HH.div_
        [ HH.text "stroke-width"
        , numberInput "layer-info.stroke-width" stroke.width \x ->
            actions.editLayer _ { stroke { width = x } }
        ]
    , HH.div_
        [ HH.text "dash-offset"
        , numberInput "layer-info.dash-offset" stroke.dashOffset \x ->
            actions.editLayer _ { stroke { dashOffset = x } }
        ]
    , HH.div_
        [ HH.text "dash-array"
        , HH.input
            [ HP.value stroke.dashArray
            , HE.onValueInput \x ->
                actions.editLayer _ { stroke { dashArray = x } }
            ]
        ]
    , HH.div_
        [ HH.text "miter-limit"
        , numberInput "layer-info.miter-limit" stroke.miterLimit \x ->
            actions.editLayer _ { stroke { miterLimit = x } }
        ]
    , drawPath { editCommand: actions.editCommand } drawPath'
    ]
