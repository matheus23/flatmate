module Data.ArrayBuffer exposing (ArrayBuffer, decode, encode)

import Json.Decode as D
import Json.Encode as E


type ArrayBuffer
    = ArrayBuffer D.Value


decode : D.Decoder ArrayBuffer
decode =
    D.map ArrayBuffer D.value


encode : ArrayBuffer -> E.Value
encode (ArrayBuffer value) =
    value
