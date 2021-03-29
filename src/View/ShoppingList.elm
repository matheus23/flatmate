module View.ShoppingList exposing (..)

import Css
import FeatherIcons
import Html.Attributes
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, attribute, classList, css, disabled, for, id, placeholder, property, src, style, title, type_, value)
import Html.Styled.Events as Events
import Html.Styled.Keyed as Keyed
import Json.Encode as E
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)
import View.Common


view : List (Html msg) -> Html msg
view content =
    ul
        [ css
            [ space_y_5
            , px_8
            ]
        ]
        content


emptyState : Html msg
emptyState =
    div
        [ css
            [ flex
            , flex_col
            , items_center
            , Css.height (Css.rem (400 / 16))
            ]
        ]
        [ View.Common.icon
            [ css
                [ text_flatmate_500
                , mt_auto
                ]
            ]
            { icon = FeatherIcons.checkCircle
            , sizePx = 64
            }
        , span
            [ css
                [ mt_8
                , mb_auto
                , text_flatmate_400
                ]
            ]
            [ text "All done! All shopping list items checked off." ]
        ]


actions : List (Html msg) -> Html msg
actions content =
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


actionButton : List (Attribute msg) -> { icon : FeatherIcons.Icon, name : String, onClick : msg } -> Html msg
actionButton attributes element =
    button
        (List.append attributes
            [ Events.onClick element.onClick
            , css
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
        [ View.Common.icon
            [ css
                [ text_gray_700
                , mr_2
                ]
            ]
            { icon = element.icon
            , sizePx = 24
            }
        , text element.name
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


item : { checked : Bool, onCheck : msg, content : List (Html msg) } -> Html msg
item { checked, onCheck, content } =
    button
        [ css
            [ itemStyles.height
            , itemStyles.padding
            , w_full
            , text_left
            , View.Common.focusable

            --
            , View.Common.cssWhen (not checked) [ itemStyles.background ]
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


itemAmount : List (Attribute msg) -> String -> Html msg
itemAmount attributes amount =
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


itemInputHeight : Css.Style
itemInputHeight =
    h_32


itemInputSpacer : Html msg
itemInputSpacer =
    div
        [ css
            [ itemInputHeight
            , flex_shrink_0
            ]
        ]
        []


itemInput :
    List (Attribute msg)
    ->
        { onSubmit : msg
        , onInput : String -> msg
        , value : String
        }
    -> Html msg
itemInput attributes element =
    form
        (List.append attributes
            [ Events.onSubmit element.onSubmit
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
                , itemInputHeight

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
            , Events.onInput element.onInput
            , value element.value
            , css
                [ itemStyles.background
                , itemStyles.font
                , itemStyles.textColor
                , itemStyles.textSize
                , itemStyles.padding
                , itemStyles.height
                , w_full
                , View.Common.focusable
                ]
            ]
            []
        , button
            [ type_ "submit"
            , css
                [ View.Common.doubleBorderedStyle
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


headerIcon : { icon : FeatherIcons.Icon, disabled : Bool, styles : List Css.Style } -> Html msg
headerIcon element =
    element.icon
        |> FeatherIcons.withSize 24
        |> FeatherIcons.toHtml []
        |> fromUnstyled
        |> List.singleton
        |> button
            [ disabled element.disabled
            , property "disabled" (E.bool element.disabled)
            , css
                [ Css.batch element.styles
                , Css.disabled
                    [ text_flatmate_300 ]
                , Css.hover
                    [ bg_flatmate_100
                    , bg_opacity_50
                    ]
                , Css.active
                    [ transform_gpu
                    , scale_90
                    ]
                , rounded_full
                , text_flatmate_700
                , p_3
                , View.Common.focusable
                ]
            ]
