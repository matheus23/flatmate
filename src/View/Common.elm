module View.Common exposing (..)

import Css
import Css.Global
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, attribute, css, for, id, placeholder, src, style, title, type_, value)
import Html.Styled.Events as Events
import Html.Styled.Keyed as Keyed
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)


globalStyles : List Css.Global.Snippet
globalStyles =
    [ Css.Global.selector "html"
        [ Css.backgroundImage (Css.url "/desktop-background.svg")
        , Css.backgroundSize Css.cover
        , h_full
        , overflow_x_hidden
        ]
    , Css.Global.selector "body"
        [ flex
        , flex_col
        , min_h_full
        ]
    ]


view : Html msg
view =
    div
        [ css
            [ flex
            , flex_grow
            ]
        ]
        [ Css.Global.global globalStyles
        , div
            [ css
                [ flex
                , flex_col
                , flex_grow
                , max_w_md
                , shadow_xl
                , bg_white
                , mx_auto
                , my_5
                ]
            ]
            [ span [ css [ m_auto ] ] [ text "Hi :)" ] ]
        ]
