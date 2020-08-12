module Main exposing (main)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)


main =
    Html.Styled.toUnstyled <|
        div [ css [ flex, flex_col ] ]
            [ span [ css [ mx_auto, text_5xl, font_extrabold ] ] [ text "Yo" ]
            , h1 [ css [ mt_8, text_center ] ] [ text "This should be unstyled!" ]
            ]
