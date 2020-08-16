module View exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, attribute, css, for, id, placeholder, src, title, type_, value)
import Html.Styled.Events as Events
import Html.Styled.Keyed as Keyed
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)


shoppingList : { input : Html msg, items : List ( String, Html msg ) } -> Html msg
shoppingList { items, input } =
    div [ css [ py_24, flex, flex_col ] ]
        [ div
            [ css
                [ flex
                , flex_col
                , mx_auto
                , max_w_lg
                , w_full
                ]
            ]
            [ Keyed.ul [ css [ flex, flex_col ] ] items
            , input
            ]
        ]


shoppingListItem : { name : String, onClick : msg } -> Html msg
shoppingListItem { name, onClick } =
    li [ css [ flex, flex_row, mb_4 ] ]
        [ div [ css [ flex_grow ] ] [ text name ]
        , button [ Events.onClick onClick ] [ text "☠" ]
        ]


shoppingListInput : { inputText : String, onSubmit : msg, onInput : String -> msg } -> Html msg
shoppingListInput { inputText, onSubmit, onInput } =
    form
        [ css [ flex, flex_row ]
        , Events.onSubmit onSubmit
        ]
        [ input
            [ type_ "text"
            , id shoppingListInputInfo.id
            , attribute "aria-label" shoppingListInputInfo.label
            , placeholder "Milch / Eier / Kartoffeln"
            , value inputText
            , Events.onInput onInput
            , css [ w_full ]
            ]
            []
        , input
            [ type_ "submit"
            , css [ ml_2 ]
            , value "Add"
            ]
            []
        ]


shoppingListInputInfo : { id : String, label : String }
shoppingListInputInfo =
    { id = "shopping-list-input"
    , label = "New Shopping List Item"
    }
