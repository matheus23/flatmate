module Data.FileSystem exposing (FileSystem, decode, encode)

import Json.Decode as D
import Json.Encode as E


type FileSystem
    = FileSystem D.Value


decode : D.Decoder FileSystem
decode =
    D.map FileSystem D.value


encode : FileSystem -> E.Value
encode (FileSystem value) =
    value
