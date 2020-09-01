module Main exposing (..)

import Browser
import Codec
import Data
import Effect exposing (Effect)
import Html
import Html.Styled
import Http
import Json.Decode
import List.Extra as List
import View.ShoppingList



---- MODEL ----


type alias Model =
    { shoppingItems : List Data.Item
    , inputText : String
    }


init : ( Model, Effect Msg )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , Effect.Http
        { url = "http://localhost:8888/v1/buckets/flatmate/collections/items/records"
        , method = "GET"
        , body = Effect.EmptyBody
        , expect =
            Effect.expectJson
                FetchedShoppingItems
                (Json.Decode.field "data"
                    (Codec.decoder (Codec.list Data.codecItem))
                )
        }
    )



---- UPDATE ----


type Msg
    = NoOp
    | FetchedShoppingItems (Result Http.Error (List Data.Item))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.None )

        FetchedShoppingItems result ->
            ( case result of
                Err _ ->
                    model

                Ok items ->
                    { model | shoppingItems = items }
            , Effect.None
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
                { addItemInputValue = ""
                , onItemInput = \_ -> NoOp
                , onItemAdd = NoOp
                , onClearItems = NoOp
                }
            }
        )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init |> Tuple.mapSecond Effect.perform
        , update = \msg model -> update msg model |> Tuple.mapSecond Effect.perform
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
