module Main exposing (..)

import Browser
import Html
import Html.Styled exposing (Html, div, h1, img, text)
import Html.Styled.Attributes exposing (css, src)
import Tailwind.Breakpoints exposing (..)
import Tailwind.Utilities exposing (..)



---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    Html.Styled.toUnstyled <|
        div
            [ css
                [ bg_purple_500
                , atBreakpoint [ ( sm, bg_red_800 ), ( lg, bg_green_200 ) ]
                ]
            ]
            [ img [ src "/logo.svg" ] []
            , h1 [] [ text "Your Elm App is working!" ]
            ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
