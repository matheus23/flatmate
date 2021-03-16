module View.Common exposing (..)

import Assets
import Css
import Css.Animations
import Css.Global
import FeatherIcons
import Html.Attributes
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


appShell : List (Html msg) -> List (Html msg)
appShell content =
    [ header
        [ css
            [ bg_flatmate_200
            , px_5
            , flex
            , flex_row
            , flex_shrink_0
            , h_16
            , items_center
            , backgroundImage Assets.headerCircle
            , Css.backgroundRepeat Css.noRepeat
            , border_flatmate_300
            , shadow_lg
            ]
        ]
        [ h1
            [ css
                [ text_white
                , text_3xl
                , font_bold
                , font_base
                ]
            ]
            [ text "Flatmate" ]
        ]
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
        content
    ]


shoppingList : List (Html msg) -> Html msg
shoppingList content =
    ul
        [ css
            [ space_y_5
            , px_8
            ]
        ]
        content


shoppingListActions : List (Html msg) -> Html msg
shoppingListActions content =
    div
        [ css
            [ flex
            , flex_row
            , items_center
            , mx_auto
            , mt_8
            , px_8
            ]
        ]
        content


shoppingListActionButton : List (Attribute msg) -> { icon : FeatherIcons.Icon, name : String } -> Html msg
shoppingListActionButton attributes { icon, name } =
    button
        (List.append attributes
            [ css
                [ flex
                , flex_row
                , font_base
                , text_gray_800
                , py_2
                , px_3
                , rounded_lg
                , transition_colors
                , border_2
                , border_transparent
                , duration_200
                , Css.focus
                    [ bg_flatmate_100
                    , outline_none
                    , border_2
                    , border_flatmate_300
                    ]
                , Css.active
                    [ bg_flatmate_200 ]
                ]
            ]
        )
        [ icon
            |> FeatherIcons.withSize 24
            |> wrapIcon
                [ css
                    [ text_gray_700
                    , mr_2
                    ]
                ]
        , text name
        ]


itemStyles : { background : Css.Style, textColor : Css.Style, font : Css.Style, textSize : Css.Style, padding : Css.Style, height : Css.Style }
itemStyles =
    { background = bg_flatmate_100
    , textColor = text_gray_900
    , font = font_base
    , textSize = text_xl
    , padding = px_5
    , height = Css.minHeight (Css.rem (24 / 16))
    }


shoppingListItem : { checked : Bool, onCheck : msg, content : List (Html msg) } -> Html msg
shoppingListItem { checked, onCheck, content } =
    button
        [ css
            [ itemStyles.height
            , itemStyles.padding
            , w_full
            , text_left
            , focusable

            --
            , cssWhen (not checked) [ itemStyles.background ]
            , transition_colors
            , duration_200
            ]
        , Events.onClick onCheck
        ]
        [ span
            [ css
                [ itemStyles.font
                , itemStyles.textSize
                , flex
                , flex_row
                , whitespace_pre_wrap

                --
                , transition
                , duration_200
                , if checked then
                    Css.batch
                        [ text_gray_500
                        , line_through
                        , Css.property "text-decoration-thickness" "2px"
                        ]

                  else
                    itemStyles.textColor
                ]
            ]
            content
        ]


shoppingListItemAmount : List (Attribute msg) -> String -> Html msg
shoppingListItemAmount attributes amount =
    span
        (List.append attributes
            [ css
                [ rounded
                , bg_flatmate_300
                , text_white
                , px_1
                ]
            ]
        )
        [ text amount ]


shoppingListInputHeight : Css.Style
shoppingListInputHeight =
    h_32


shoppingListInputSpacer : Html msg
shoppingListInputSpacer =
    div
        [ css
            [ shoppingListInputHeight
            , flex_shrink_0
            ]
        ]
        []


shoppingListInput : List (Attribute msg) -> { onAdd : msg } -> Html msg
shoppingListInput attributes { onAdd } =
    form
        (List.append attributes
            [ Events.onSubmit onAdd
            , css
                [ flex
                , flex_row
                , items_center

                -- Sizing
                , w_full
                , px_8

                -- Positioning
                , absolute
                , bottom_0
                , inset_x_0
                , shoppingListInputHeight

                -- Background
                , Css.backgroundImage
                    (Css.linearGradient2
                        Css.toTop
                        (Css.stop (Css.hex "fff"))
                        (Css.stop2 (Css.hex "fff") (Css.pct 60))
                        [ Css.stop (Css.rgba 255 255 255 0) ]
                    )
                ]
            ]
        )
        [ input
            [ type_ "text"
            , css
                [ itemStyles.background
                , itemStyles.font
                , itemStyles.textColor
                , itemStyles.textSize
                , itemStyles.padding
                , itemStyles.height
                , w_full
                , focusable
                ]
            ]
            []
        , button
            [ css
                [ doubleBorderedStyle
                , h_12
                , w_12
                , text_flatmate_100
                , flex_shrink_0
                , flex
                , flex_row
                , items_center
                ]
            ]
            [ FeatherIcons.plus
                |> FeatherIcons.withSize 24
                |> FeatherIcons.toHtml
                    [ Html.Attributes.style "display" "inline"
                    , Html.Attributes.style "margin" "auto"
                    ]
                |> fromUnstyled
            ]
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
        , focusable
        , shadow_double_bordered
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


wrapIcon : List (Attribute msg) -> FeatherIcons.Icon -> Html msg
wrapIcon attributes icon =
    icon
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
