module View.Common exposing (..)

import Assets
import Css
import Css.Animations
import Css.Global
import Css.Media
import FeatherIcons
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
                [ backgroundImage Assets.desktopBackground
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
        -- [ -- loadingScreen { message = "Authenticating..." }
        -- -- signinScreen
        -- ]
        shoppingList


shoppingList : List (Html msg)
shoppingList =
    [ header
        [ css
            [ bg_flatmate_200
            , px_5
            , flex
            , flex_row
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
            , flex_row
            , px_8
            , py_8
            , space_y_8
            ]
        ]
        [ ul
            [ css [ space_y_4 ] ]
            [ shoppingListItem { checked = True, content = [ shoppingListItemAmount "1l", text " Milk" ] }
            , shoppingListItem { checked = False, content = [ text "Butter" ] }
            , shoppingListItem { checked = False, content = [ text "Eggs" ] }
            , shoppingListItem { checked = True, content = [ text "Screwdriver" ] }
            , shoppingListItem { checked = False, content = [ text "Avocado" ] }
            , shoppingListItem { checked = True, content = [ text "Cherries" ] }
            ]
        , shoppingListActionButton []
            { icon = FeatherIcons.trash2
            , name = "Clear Checked"
            }
        ]
    ]


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
                , Css.property "transition-property" "background-color"
                , border_2
                , border_transparent
                , duration_200
                , Css.focus
                    [ bg_flatmate_100
                    , outline_none
                    , border_2
                    , border_flatmate_200
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
                    , mr_3
                    ]
                ]
        , text name
        ]


shoppingListItem : { checked : Bool, content : List (Html msg) } -> Html msg
shoppingListItem { checked, content } =
    div
        [ css
            [ h_5
            , w_full
            , px_5
            , relative

            --
            , if checked then
                Css.batch []

              else
                bg_flatmate_100
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
                , Css.bottom (Css.px -4)

                --
                , if checked then
                    Css.batch
                        [ text_gray_500
                        , line_through
                        ]

                  else
                    text_gray_900
                ]
            ]
            content
        ]


shoppingListItemAmount : String -> Html msg
shoppingListItemAmount amount =
    span
        [ css
            [ rounded
            , bg_flatmate_300
            , text_white
            , Css.padding2 Css.zero (Css.px 6)
            , Css.margin2 Css.zero (Css.px -2)
            ]
        ]
        [ text amount ]


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
                    , shadow_2xl
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
            , backgroundImage Assets.signinCircle
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
                , max_w_sm
                ]
            ]
            [ text "Write shopping lists faster and never forget groceries! For you and your flatmates." ]
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


backgroundImage : String -> Css.Style
backgroundImage base64encodedSvg =
    Css.property "background-image"
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


wrapIcon : List (Attribute msg) -> FeatherIcons.Icon -> Html msg
wrapIcon attributes icon =
    icon
        |> FeatherIcons.toHtml []
        |> fromUnstyled
        |> List.singleton
        |> span attributes
