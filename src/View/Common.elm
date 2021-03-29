module View.Common exposing (..)

import Assets
import Css
import Css.Animations
import Css.Global
import FeatherIcons
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, attribute, css, for, id, placeholder, src, style, title, type_, value)
import Html.Styled.Events as Events
import Html.Styled.Keyed as Keyed
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)


globalStyles : List Css.Global.Snippet
globalStyles =
    List.append Tailwind.Utilities.globalStyles
        [ Css.Global.selector "html"
            [ h_full
            , md
                [ backgroundImage Assets.desktopBackground
                , Css.backgroundSize Css.cover
                ]
            ]
        , Css.Global.selector "body"
            [ flex
            , flex_col
            , min_h_full
            , h_full
            ]
        ]


desktopScaffolding : List (Html msg) -> Html msg
desktopScaffolding content =
    div
        [ css
            [ flex
            , flex_grow
            , max_h_full
            ]
        ]
        [ Css.Global.global globalStyles
        , div
            [ css
                [ md
                    [ max_w_xl
                    , shadow_2xl
                    , mx_auto
                    , my_5
                    ]
                , flex
                , flex_col
                , flex_grow
                , bg_white
                , relative
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
            , overflow_hidden
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


signinScreen : { onSignIn : msg } -> Html msg
signinScreen { onSignIn } =
    div
        [ css
            [ flex_grow
            , flex
            , flex_col
            , px_16
            , py_8
            , backgroundImage Assets.signinCircle
            , Css.backgroundSize Css.contain
            , Css.backgroundRepeat Css.noRepeat
            , space_y_8
            , overflow_y_auto
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
                , max_w_sm
                ]
            ]
            [ text "Write shopping lists faster and never forget groceries! For you and your flatmates." ]
        , button
            [ css
                [ doubleBorderedStyle
                , mx_auto
                , flex
                , flex_row
                , py_2
                , px_4
                , text_xl
                , text_white
                , font_base
                ]
            , Events.onClick onSignIn
            ]
            [ img [ css [ w_5, mr_2 ], src (base64Data Assets.fissionLogoWhite) ] []
            , text "Sign in with Fission"
            ]
        ]


appShell : { headerIcons : List (Html msg), main : List (Html msg) } -> List (Html msg)
appShell element =
    [ header
        [ css
            [ bg_flatmate_200
            , px_5
            , h_16
            , flex
            , flex_row
            , flex_shrink_0
            , items_center
            , space_x_2
            , backgroundImage Assets.headerCircle
            , Css.backgroundRepeat Css.noRepeat
            , border_flatmate_300
            , shadow_lg
            ]
        ]
        (List.append
            [ h1
                [ css
                    [ text_white
                    , text_3xl
                    , font_bold
                    , font_base
                    , mr_auto
                    ]
                ]
                [ text "Flatmate" ]
            ]
            element.headerIcons
        )
    , main_
        [ css
            [ flex_grow
            , flex
            , flex_col
            , pt_8
            , overflow_y_auto
            , max_h_full
            , Css.Global.children
                [ Css.Global.everything
                    [ flex_shrink_0 ]
                ]
            ]
        ]
        element.main
    ]



--


focusable : Css.Style
focusable =
    Css.batch
        [ Css.focus [ outline_none ]
        , Css.pseudoClass "focus-visible"
            [ ring_2
            , ring_opacity_80
            , ring_flatmate_300
            ]
        ]


doubleBorderedStyle : Css.Style
doubleBorderedStyle =
    Css.batch
        [ rounded_full
        , bg_flatmate_300
        , shadow_flatmate_100_300
        , Css.active
            [ bg_flatmate_500
            , shadow_flatmate_100_500
            ]
        , focusable
        , ring_offset_4
        ]



--


backgroundImage : String -> Css.Style
backgroundImage base64encodedSvg =
    Css.property "background-image"
        ("url('" ++ base64Data base64encodedSvg ++ "')")


base64Data : String -> String
base64Data base64encodedSvg =
    "data:image/svg+xml;base64," ++ base64encodedSvg


icon : List (Attribute msg) -> { sizePx : Float, icon : FeatherIcons.Icon } -> Html msg
icon attributes element =
    element.icon
        |> FeatherIcons.withSize (element.sizePx / 16)
        |> FeatherIcons.withSizeUnit "rem"
        |> FeatherIcons.toHtml []
        |> fromUnstyled
        |> List.singleton
        |> span attributes


cssWhen : Bool -> List Css.Style -> Css.Style
cssWhen prop list =
    Css.batch (when prop list)


when : Bool -> List a -> List a
when predicate list =
    if predicate then
        list

    else
        []
