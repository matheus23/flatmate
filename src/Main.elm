module Main exposing (..)

import Browser
import Effect exposing (Effect)
import Html
import Html.Styled
import Kinto
import List.Extra as List
import View.ShoppingList



---- MODEL ----


type alias Model =
    { shoppingItems : List { title : String, id : Kinto.Id }
    , inputText : String
    }


init : ( Model, Effect )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , Effect.KintoSend Kinto.FetchList
    )



---- UPDATE ----


type Msg
    = NoOp
    | RemoveShoppingItem Kinto.Id
    | ChangeNewShoppingItem String
    | AddNewShoppingItem
    | ReceivedShoppingListUpdate (List { title : String, id : Kinto.Id })


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.None )

        RemoveShoppingItem id ->
            ( model
            , Effect.KintoSend (Kinto.DeleteItem id)
            )

        ChangeNewShoppingItem newName ->
            ( { model | inputText = newName }
            , Effect.None
            )

        AddNewShoppingItem ->
            ( { model | inputText = "" }
            , Effect.KintoSend (Kinto.Add { title = model.inputText })
            )

        ReceivedShoppingListUpdate newList ->
            ( { model | shoppingItems = newList }
            , Effect.None
            )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        View.ShoppingList.view



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
    Kinto.receive NoOp ReceivedShoppingListUpdate
