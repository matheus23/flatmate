module View.ShoppingList exposing (..)

import Css
import Css.Global
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, attribute, css, for, id, placeholder, src, style, title, type_, value)
import Html.Styled.Events as Events
import Html.Styled.Keyed as Keyed
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)


view : Html msg
view =
    div
        [ css
            [ flex
            , flex_col
            , min_h_screen
            , mx_auto
            , max_w_lg
            ]
        ]
        [ -- TODO switch to Document.application, so that this doesn't have to be included here
          Css.Global.global
            [ Css.Global.selector "html"
                [ bg_gray_100
                , overflow_x_hidden
                ]
            , Css.Global.selector "body"
                [ flex
                , flex_col
                ]
            ]
        , navbar
        , shopList
        , actions
        ]


navbar : Html msg
navbar =
    div
        [ css
            [ flex
            , flex_row
            , space_x_3
            , px_2
            , pt_2
            , bg_gray_100
            ]
        ]
        [ logo
        , div
            [ css
                [ box_border
                , border_b_2
                , border_flatmate_300
                , flex_grow
                ]
            ]
            []
        ]


logo : Html msg
logo =
    div
        [ css
            [ font_base
            , font_bold
            , text_2xl
            , text_white
            , bg_flatmate_300
            , w_12
            , h_10
            , flex
            , rounded
            ]
        ]
        [ span [ css [ m_auto ] ] [ text "Fm" ] ]



-- SHOP SECTIONS


shopList : Html msg
shopList =
    div
        [ css
            [ p_5
            ]
        ]
        [ shopGenericHeading
        , entryList
        , shopHeading "Dm"
        , entryList
        ]


shopGenericHeading : Html msg
shopGenericHeading =
    div
        [ css
            [ flex
            , py_4
            ]
        ]
        [ input
            [ type_ "text"
            , placeholder "Allgemeines Zeug"
            , css
                [ font_base
                , text_lg
                , font_bold
                , mx_auto
                , w_40
                , fatUnderline { from = 0, to = 20 }
                , backlighted
                , bg_transparent
                , flatmateSelection
                , Css.pseudoElement "placeholder"
                    [ text_flatmate_200
                    , opacity_100
                    , text_center
                    ]
                ]
            ]
            []
        ]


shopHeading : String -> Html msg
shopHeading shop =
    div
        [ css
            [ flex
            , py_4
            ]
        ]
        [ h4
            [ css
                [ font_base
                , text_lg
                , font_bold
                , mx_auto
                , fatUnderline { from = 10, to = 35 }
                , backlighted
                , flatmateSelection
                ]
            ]
            [ text shop ]
        ]



-- ENTRY LIST


entryList : Html msg
entryList =
    div
        [ css [ space_y_4 ] ]
        [ entry
            { enabled = True
            , content =
                [ text "Milch, "
                , entryAmount "2"
                ]
            }
        , entry
            { enabled = True
            , content =
                [ entryAmount "12"
                , text " Eier"
                ]
            }
        , entry
            { enabled = True, content = [ text "Zwiebeln" ] }
        , entry
            { enabled = False
            , content = [ text "2 Joghurt" ]
            }
        ]


entry : { enabled : Bool, content : List (Html msg) } -> Html msg
entry { enabled, content } =
    div
        [ css
            [ h_5
            , w_full
            , relative

            --
            , if enabled then
                bg_gray_200

              else
                Css.batch []
            ]
        ]
        [ span
            [ css
                [ font_base
                , text_lg
                , absolute
                , flex
                , flex_row
                , whitespace_pre
                , flatmateSelection
                , Css.bottom (Css.px -4)

                --
                , if enabled then
                    text_gray_900

                  else
                    Css.batch
                        [ text_gray_500
                        , line_through
                        ]
                ]
            ]
            content
        ]


entryAmount : String -> Html msg
entryAmount amount =
    span
        [ css
            [ rounded
            , bg_flatmate_300
            , text_white
            , Css.padding2 Css.zero (Css.px 2)
            , Css.margin2 Css.zero (Css.px -2)
            ]
        ]
        [ text amount ]



-- ACTIONS SECTION


actions : Html msg
actions =
    div
        [ css
            [ mt_auto
            , px_5
            , py_3
            , space_y_2
            ]
        ]
        [ entryInput
        , deleteCheckedButton
        ]


entryInput : Html msg
entryInput =
    form
        [ css
            [ flex
            , flex_row
            , space_x_2
            ]
        ]
        [ input
            [ type_ "text"
            , placeholder "Tofu oder Kartoffeln?"
            , css
                [ mx_3
                , my_2
                , bg_gray_200
                , w_full
                , min_w_0
                , font_base
                , text_lg
                , text_gray_900
                , flatmateSelection
                , box_border
                , border_b_2
                , border_gray_200
                , pseudoClassActive [ border_flatmate_300 ]
                ]
            ]
            []
        , input
            [ type_ "submit"

            -- TODO Add icon
            , value "Add"
            , css
                [ w_16
                , flex_grow
                , font_base
                , text_lg
                , text_white
                , bg_flatmate_500
                , rounded
                , box_border
                , border_2
                , border_flatmate_500
                , pseudoClassActive [ border_flatmate_300 ]
                ]
            ]
            []
        ]


deleteCheckedButton : Html msg
deleteCheckedButton =
    button
        [ css
            [ rounded
            , bg_flatmate_200
            , font_base
            , text_flatmate_700
            , text_lg
            , text_center
            , w_full
            , py_1
            ]
        ]
        -- TODO Add Icon
        [ text "Abgehaktes Löschen" ]



-- UTILITIES


pseudoClassActive : List Css.Style -> Css.Style
pseudoClassActive activeStyle =
    Css.batch
        [ Css.hover activeStyle
        , Css.focus activeStyle
        , Css.active activeStyle
        ]


fatUnderline : { from : Int, to : Int } -> Css.Style
fatUnderline { from, to } =
    Css.property
        "background-image"
        (String.join ","
            [ "linear-gradient(to top"
            , "rgba(255, 255, 255, 0)"
            , "rgba(255, 255, 255, 0) " ++ String.fromInt from ++ "%"
            , "#90B3FF " ++ String.fromInt from ++ "%"
            , "#90B3FF " ++ String.fromInt to ++ "%"
            , "rgba(255, 255, 255, 0) " ++ String.fromInt to ++ "%);"
            ]
        )


backlighted : Css.Style
backlighted =
    Css.property
        "text-shadow"
        "0.5px 0.5px #FFFFFF"


flatmateSelection : Css.Style
flatmateSelection =
    Css.pseudoElement "selection"
        [ text_white
        , bg_flatmate_300
        , Css.textShadow Css.none
        ]
