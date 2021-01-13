port module Ports exposing (..)

import Json.Decode as Json


port redirectToLobby : () -> Cmd msg


port initializedWebnative : (Json.Value -> msg) -> Sub msg
