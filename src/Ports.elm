port module Ports exposing (..)

import Json.Decode as Json


port initializedWebnative : (Json.Value -> msg) -> Sub msg


port redirectToLobby : () -> Cmd msg


port log : String -> Cmd msg


port heartbeat : ({} -> msg) -> Sub msg
