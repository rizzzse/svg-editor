module SvgEditor.View.LayerInfo where

import Prelude
import Data.Maybe (fromJust)
import Data.Tuple (Tuple(..), fst, snd)
import Data.Array (find)
import Partial.Unsafe (unsafePartial)
import Effect.Aff (Aff)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Svg.Attributes.StrokeLineCap (StrokeLineCap(..), printStrokeLineCap)
import Halogen.Svg.Attributes.StrokeLineJoin (StrokeLineJoin(..), printStrokeLineJoin)
import SvgEditor.Layer (Layer, FillRule(..))
import SvgEditor.PathCommand (PathCommand)
import SvgEditor.View.DrawPath (drawPath)
import SvgEditor.View.NumberInput (numberInput, Slot)

-- TODO: value
select :: forall a b x. Array x -> (x -> String) -> (x -> b) -> HH.HTML a b
select xs print f =
  let
    ys = xs # map \x -> Tuple (print x) x
  in
    HH.select
      [ HE.onValueInput \x ->
          f $ snd $ unsafePartial fromJust $ ys # find (fst >>> (==) x)
      ]
      $ ys
      # map \x -> let name = fst x in HH.option [ HP.value name ] [ HH.text name ]

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
    , stringInput'
        { name: "fill-color"
        , value: fill.color
        , onChange: \x -> _ { fill { color = x } }
        }
    , numberInput'
        { name: "fill-opacity"
        , value: fill.opacity
        , onChange: \x -> _ { fill { opacity = clamp 0.0 1.0 x } }
        }
    , selectInput'
        { name: "fill-rule"
        , value: fill.rule
        , xs: [ NonZero, EvenOdd ]
        , print: show
        , onChange: \x -> _ { fill { rule = x } }
        }
    , stringInput'
        { name: "stroke-color"
        , value: stroke.color
        , onChange: \x -> _ { stroke { color = x } }
        }
    , numberInput'
        { name: "stroke-opacity"
        , value: stroke.opacity
        , onChange: \x -> _ { stroke { opacity = clamp 0.0 1.0 x } }
        }
    , numberInput'
        { name: "stroke-width"
        , value: stroke.width
        , onChange: \x -> _ { stroke { width = x } }
        }
    , numberInput'
        { name: "dash-offset"
        , value: stroke.dashOffset
        , onChange: \x -> _ { stroke { dashOffset = x } }
        }
    , stringInput'
        { name: "dash-array"
        , value: stroke.dashArray
        , onChange: \x -> _ { stroke { dashArray = x } }
        }
    , selectInput'
        { name: "line-cap"
        , value: stroke.lineCap
        , xs: [ LineCapButt, LineCapSquare, LineCapRound ]
        , print: printStrokeLineCap
        , onChange: \x -> _ { stroke { lineCap = x } }
        }
    , selectInput'
        { name: "line-join"
        , value: stroke.lineJoin
        , xs: [ LineJoinMiter, LineJoinMiterClip, LineJoinArcs, LineJoinBevel, LineJoinRound ]
        , print: printStrokeLineJoin
        , onChange: \x -> _ { stroke { lineJoin = x } }
        }
    , numberInput'
        { name: "miter-limit"
        , value: stroke.miterLimit
        , onChange: \x -> _ { stroke { miterLimit = x } }
        }
    , drawPath { editCommand: actions.editCommand } drawPath'
    ]
  where
  stringInput' { name, value, onChange } =
    input' name
      $ HH.input
          [ HP.value value
          , HE.onValueInput (actions.editLayer <<< onChange)
          ]

  numberInput' { name, value, onChange } =
    input' name
      $ numberInput ("layer-info" <> name) value (actions.editLayer <<< onChange)

  selectInput' ::
    forall b x.
    { name :: String
    , value :: x
    , xs :: Array x
    , print :: x -> String
    , onChange :: x -> Layer -> Layer
    } ->
    HH.HTML b a
  selectInput' { name, value: _, xs, print, onChange } =
    input' name
      $ select xs print (actions.editLayer <<< onChange)

  input' :: forall a b. String -> HH.HTML a b -> HH.HTML a b
  input' name input = HH.div_ [ HH.text name, input ]
