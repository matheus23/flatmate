port module ServiceWorker exposing (..)

import Platform


type alias Flags =
    ()


type alias Model =
    {}


type Msg
    = NoOp


main : Platform.Program Flags Model Msg
main =
    Platform.worker
        { init = \() -> ( {}, log "Elm ServiceWorker initialized" )
        , update = \NoOp model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }



-- PORTS


port log : String -> Cmd msg
