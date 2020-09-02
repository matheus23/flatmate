module Main exposing (..)

import Browser
import Codec
import Data
import Html
import Html.Styled
import Http
import Kinto.Routes as Routes
import List.Extra as List
import Random
import Task exposing (Task)
import Time
import UUID exposing (UUID)
import Url.Builder as Url
import View.ShoppingList



---- MODEL ----


type alias Model =
    { shoppingItems : List Data.Item
    , inputText : String
    , uuidSeeds : UUID.Seeds
    }


type alias Flags =
    { randomness : { r1 : Int, r2 : Int, r3 : Int, r4 : Int } }


init : Flags -> ( Model, Cmd Msg )
init { randomness } =
    ( { shoppingItems = []
      , inputText = ""
      , uuidSeeds =
            { seed1 = Random.initialSeed randomness.r1
            , seed2 = Random.initialSeed randomness.r2
            , seed3 = Random.initialSeed randomness.r3
            , seed4 = Random.initialSeed randomness.r4
            }
      }
    , fetchItems
        |> Task.attempt FetchedShoppingItems
    )


fetchItems : Task Http.Error (List Data.Item)
fetchItems =
    Http.task
        { url =
            Routes.toUrl
                (Url.crossOrigin "http://localhost:8888")
                (Routes.Buckets "flatmate" (Routes.Collections "items" Routes.RecordsAll))
                []
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
                ( uuid, seeds ) =
                    UUID.step model.uuidSeeds
            in
            ( { model | uuidSeeds = seeds, inputText = "" }
            , Time.now
                |> Task.andThen
                    (\now ->
                        Http.task
                            { url = "http://localhost:8888/v1/buckets/flatmate/collections/items/records/" ++ UUID.toString uuid
                            , method = "PUT"
                            , headers = []
                            , body =
                                Http.jsonBody
                                    (Codec.encodeToValue (Data.codecKintoRequest Data.codecItem)
                                        { data =
                                            { id = Data.fromUUID uuid
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


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = \msg model -> update msg model
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
