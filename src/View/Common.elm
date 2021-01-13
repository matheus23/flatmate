module View.Common exposing (..)

import Assets
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
                , background Assets.desktopBackground
                , Css.backgroundSize Css.cover
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
        [ -- loadingScreen { message = "Authenticating..." }
          signinScreen
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


signinScreen : Html msg
signinScreen =
    div
        [ css
            [ flex_grow
            , flex
            , flex_col
            , px_16
            , py_8
            , background Assets.signinCircle
            , Css.backgroundSize Css.contain
            , Css.backgroundRepeat Css.noRepeat
            , space_y_8
            ]
        ]
        [ h1
            [ css
                [ text_center
                , text_5xl
                , font_base
                , font_bold
                , text_white
                ]
            ]
            [ text "Flatmate" ]
        , img
            [ src (base64Data Assets.signinIllustration)
            , css [ w_full ]
            ]
            []
        , p
            [ css
                [ text_gray_800
                , font_base
                , text_center
                , mx_auto
                , max_w_xs
                ]
            ]
            [ text "Write shopping lists faster and never forget! For you and your flatmates." ]
        , doubleBordered button
            { outer =
                [ css
                    [ mx_auto
                    , flex
                    , flex_row
                    , focusable
                    ]
                ]
            , inner =
                [ css
                    [ flex
                    , flex_row
                    , py_2
                    , px_4
                    , text_xl
                    , text_white
                    , font_base
                    ]
                ]
            }
            [ img [ css [ w_5, mr_2 ], src (base64Data Assets.fissionLogoWhite) ] []
            , text "Sign in with Fission"
            ]
        ]


background : String -> Css.Style
background base64encodedSvg =
    Css.property "background"
        ("url('" ++ base64Data base64encodedSvg ++ "')")


base64Data : String -> String
base64Data base64encodedSvg =
    "data:image/svg+xml;base64," ++ base64encodedSvg


focusable : Css.Style
focusable =
    Css.focus
        [ outline_none
        , shadow_outline
        ]


doubleBordered :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    ->
        { outer : List (Attribute msg)
        , inner : List (Attribute msg)
        }
    -> List (Html msg)
    -> Html msg
doubleBordered node attributes content =
    node
        (List.append attributes.outer
            [ css
                [ rounded_full
                , bg_flatmate_300
                , border_flatmate_300
                , border_2
                ]
            ]
        )
        [ div
            (List.append attributes.inner
                [ css
                    [ rounded_full
                    , border_flatmate_100
                    , border_2
                    ]
                ]
            )
            content
        ]
