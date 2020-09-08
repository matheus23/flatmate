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
        { init = \() -> ( {}, Cmd.none )
        , update = \NoOp model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }



-- PORTS


port log : String -> Cmd msg
