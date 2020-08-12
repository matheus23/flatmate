port module Main exposing (..)

import Browser
import Html
import Html.Styled
import List.Extra as List
import View


port kintoSend : { command : String, shoppingItem : String } -> Cmd msg

port kintoReceive : (List {title: String, id: Id} -> msg) -> Sub msg

type alias Id = String

---- MODEL ----


type alias Model =
    { shoppingItems : List { title: String, id: Id }
    , inputText : String
    }


init : ( Model, Cmd Msg )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , kintoSend {command="list-items", shoppingItem =""}
    )



---- UPDATE ----


type Msg
    = NoOp
    | RemoveShoppingItem Id
    | ChangeNewShoppingItem String
    | AddNewShoppingItem
    | ReceivedShoppingListUpdate (List {title: String, id: String})


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RemoveShoppingItem id ->
            ( model
            , kintoSend {command="remove-item", shoppingItem = id}
            )

        ChangeNewShoppingItem newName ->
            ( { model | inputText = newName }
            , Cmd.none
            )

        AddNewShoppingItem ->
            ( { model | inputText = ""}
            , kintoSend { command = "add-item", shoppingItem = model.inputText }
            )

        ReceivedShoppingListUpdate newList ->
            ( {model | shoppingItems = newList}
            , Cmd.none
            )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.shoppingList
            { items =
                List.map
                    (\{title, id} ->
                        ( title
                        , View.shoppingListItem
                            { name = title
                            , onClick = RemoveShoppingItem id
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
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions _ =
    kintoReceive ReceivedShoppingListUpdate