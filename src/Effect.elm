module Effect exposing (..)

import Kinto


type Effect
    = None
    | KintoSend Kinto.Command


perform : Effect -> Cmd msg
perform effect =
    case effect of
        None ->
            Cmd.none

        KintoSend command ->
            Kinto.send command
