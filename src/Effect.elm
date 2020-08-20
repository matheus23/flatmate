module Effect exposing (..)

import Json.Encode as E
import Ports


type Effect
    = None
    | SendPort E.Value


perform : Effect -> Cmd msg
perform effect =
    case effect of
        None ->
            Cmd.none

        SendPort value ->
            Ports.send value
