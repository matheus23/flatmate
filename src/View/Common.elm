module View.Common exposing (..)

import Css
import Css.Animations
import Css.Global
import Css.Media
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, attribute, css, for, id, placeholder, src, style, title, type_, value)
import Html.Styled.Events as Events
import Html.Styled.Keyed as Keyed
import Tailwind exposing (..)
import Tailwind.Breakpoints exposing (..)


globalStyles : List Css.Global.Snippet
globalStyles =
    List.append Tailwind.globalStyles
        [ Css.Global.selector "html"
            [ h_full
            , md
                [ overflow_hidden
                , Css.backgroundSize Css.cover
                , Css.backgroundImage (Css.url "/desktop-background.svg")
                ]
            ]
        , Css.Global.selector "body"
            [ flex
            , flex_col
            , min_h_full
            ]
        ]


view : Html msg
view =
    desktopScaffolding
        [ loadingScreen { message = "Authenticating..." }
        ]


desktopScaffolding : List (Html msg) -> Html msg
desktopScaffolding content =
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
                , bg_white
                , md
                    [ max_w_xl
                    , shadow_xl
                    , mx_auto
                    , my_5
                    ]
                ]
            ]
            content
        ]


loadingScreen : { message : String } -> Html msg
loadingScreen { message } =
    div
        [ css
            [ flex
            , flex_col
            , items_center
            , space_y_5
            , m_auto
            ]
        ]
        [ div
            [ css
                [ w_16
                , h_16
                , rounded_full
                , bg_flatmate_300

                --
                , Css.animationName <|
                    Css.Animations.keyframes
                        [ ( 0, [ Css.Animations.transform [ Css.scale 1 ] ] )
                        , ( 100, [ Css.Animations.transform [ Css.scale 0.25 ] ] )
                        ]
                , Css.animationDuration (Css.ms 800)
                , Css.property "animation-iteration-count" "infinite"
                , Css.property "animation-direction" "alternate"
                , Css.property "animation-timing-function" "ease-in"
                ]
            ]
            []
        , span
            [ css
                [ font_base
                , text_base
                , italic
                , text_gray_800
                , font_light
                ]
            ]
            [ text message ]
        ]
