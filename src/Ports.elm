port module Ports exposing (..)

import Json.Decode as Json
import Webnative


port initializedWebnative : (Json.Value -> msg) -> Sub msg



-- Webnative-Elm Ports


port webnativeRequest : Webnative.Request -> Cmd msg


port wnfsRequest : Webnative.Request -> Cmd msg


port wnfsResponse : (Webnative.Response -> msg) -> Sub msg
