module Main exposing (..)

import Browser
import Codec
import Data
import Html
import Html.Styled
import Http
import List.Extra as List
import Task exposing (Task)
import Time
import View.ShoppingList



---- MODEL ----


type alias Model =
    { shoppingItems : List Data.Item
    , inputText : String
    }


init : ( Model, Cmd Msg )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , fetchItems
        |> Task.attempt FetchedShoppingItems
    )


fetchItems : Task Http.Error (List Data.Item)
fetchItems =
    Http.task
        { url = "http://localhost:8888/v1/buckets/flatmate/collections/items/records"
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , resolver =
            Http.stringResolver
                (Data.handleResponse
                    (Codec.decoder
                        (Data.codecKintoRequest
                            (Codec.list Data.codecItem)
                        )
                    )
                )
        , timeout = Just 5000
        }
        |> Task.map .data



---- UPDATE ----


type Msg
    = NoOp
    | FetchedShoppingItems (Result Http.Error (List Data.Item))
    | AddShoppingItem
    | OnItemInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchedShoppingItems result ->
            ( case result of
                Err _ ->
                    model

                Ok items ->
                    { model | shoppingItems = items }
            , Cmd.none
            )

        OnItemInput itemText ->
            ( { model | inputText = itemText }, Cmd.none )

        AddShoppingItem ->
            let
                id =
                    "12334"
            in
            ( model
            , Time.now
                |> Task.andThen
                    (\now ->
                        Http.task
                            { url = "http://localhost:8888/v1/buckets/flatmate/collections/items/records/" ++ id
                            , method = "PUT"
                            , headers = []
                            , body =
                                Http.jsonBody
                                    (Codec.encodeToValue (Data.codecKintoRequest Data.codecItem)
                                        { data =
                                            { id = Data.Id id -- TODO Generate UUIDv4
                                            , lastModified = now
                                            , name = model.inputText
                                            , amount = Nothing
                                            , shop = Nothing
                                            , checked = False
                                            }
                                        }
                                    )
                            , resolver = Http.stringResolver (\_ -> Ok ())
                            , timeout = Just 5000
                            }
                            |> Task.andThen (\_ -> fetchItems)
                    )
                |> Task.attempt FetchedShoppingItems
            )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.ShoppingList.view
            { shops =
                [ View.ShoppingList.shopGenericHeading
                , View.ShoppingList.itemList
                    (model.shoppingItems
                        |> List.map
                            (\item ->
                                View.ShoppingList.item
                                    { checked = item.checked
                                    , content = [ Html.Styled.text item.name ]
                                    }
                            )
                    )
                , View.ShoppingList.shopHeading "Dm"
                , View.ShoppingList.itemList []
                ]
            , actionSection =
                { addItemInputValue = model.inputText
                , onItemInput = OnItemInput
                , onItemAdd = AddShoppingItem
                , onClearItems = NoOp
                }
            }
        )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = \msg model -> update msg model
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
