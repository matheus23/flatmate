module Main exposing (..)

import Browser
import Html
import Html.Styled
import View



---- MODEL ----


type alias Model =
    { shoppingItems : List String
    }


init : ( Model, Cmd Msg )
init =
    ( { shoppingItems = [ "Milch", "Stuff" ] }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled
        (View.shoppingList
            { items =
                List.map (\name -> View.shoppingListItem { name = name, onClick = NoOp })
                    model.shoppingItems
            , input =
                View.shoppingListInput
                    { onSubmit = NoOp
                    , onInput = \_ -> NoOp
                    , inputText = ""
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
