module Main exposing (..)

import Browser
import Effect exposing (Effect)
import Html
import Html.Styled
import List.Extra as List
import Ports
import View.ShoppingList



---- MODEL ----


type alias Model =
    { shoppingItems : List { title : String, id : Ports.Id }
    , inputText : String
    }


init : ( Model, Effect )
init =
    ( { shoppingItems = []
      , inputText = ""
      }
    , Effect.None
    )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.None )



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
    Sub.none
