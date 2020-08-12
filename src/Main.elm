module Main exposing (..)

import Browser
import Html
import Html.Styled
import Kinto
import List.Extra as List
import View



---- MODEL ----


type alias Model =
    { shoppingItems : List { title : String, id : Kinto.Id }
    , inputText : String
    }


init : ( Model, Cmd Msg )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , Kinto.send <| Kinto.FetchList
    )



---- UPDATE ----


type Msg
    = NoOp
    | RemoveShoppingItem Kinto.Id
    | ChangeNewShoppingItem String
    | AddNewShoppingItem
    | ReceivedShoppingListUpdate (List { title : String, id : Kinto.Id })


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RemoveShoppingItem id ->
            ( model
            , Kinto.send <| Kinto.RemoveItem id
            )

        ChangeNewShoppingItem newName ->
            ( { model | inputText = newName }
            , Cmd.none
            )

        AddNewShoppingItem ->
            ( { model | inputText = "" }
            , Kinto.send <| Kinto.Add { title = model.inputText }
            )

        ReceivedShoppingListUpdate newList ->
            ( { model | shoppingItems = newList }
            , Cmd.none
            )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.shoppingList
            { items =
                List.map
                    (\{ title, id } ->
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
    Kinto.receive ReceivedShoppingListUpdate
