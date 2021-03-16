port module Ports exposing (..)

import Json.Decode as Json
import Webnative


port initializedWebnative : (Json.Value -> msg) -> Sub msg


port log : String -> Cmd msg


port heartbeat : ({} -> msg) -> Sub msg



-- Webnative-Elm Ports


port webnativeRequest : Webnative.Request -> Cmd msg


port webnativeResponse : (Webnative.Response -> msg) -> Sub msg
