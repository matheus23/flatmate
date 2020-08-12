port module Main exposing (..)

import Browser
import Html
import Html.Styled
import List.Extra as List
import View


port kintoSend : { command : String, shoppingItem : String } -> Cmd msg



---- MODEL ----


type alias Model =
    { shoppingItems : List String
    , inputText : String
    }


init : ( Model, Cmd Msg )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | RemoveShoppingItem Int
    | ChangeNewShoppingItem String
    | AddNewShoppingItem


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RemoveShoppingItem index ->
            ( { model | shoppingItems = List.removeAt index model.shoppingItems }
            , Cmd.none
            )

        ChangeNewShoppingItem newName ->
            ( { model | inputText = newName }
            , Cmd.none
            )

        AddNewShoppingItem ->
            ( { model | inputText = "", shoppingItems = model.inputText :: model.shoppingItems }
            , kintoSend { command = "add-item", shoppingItem = model.inputText }
            )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.shoppingList
            { items =
                List.indexedMap
                    (\index name ->
                        ( name
                        , View.shoppingListItem
                            { name = name
                            , onClick = RemoveShoppingItem index
                            }
                        )
                    )
                    model.shoppingItems
            , input =
                View.shoppingListInput
                    { onSubmit = AddNewShoppingItem
                    , onInput = ChangeNewShoppingItem
                    , inputText = model.inputText
                    }
            }
        )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
