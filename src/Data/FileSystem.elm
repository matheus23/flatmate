module Data.FileSystem exposing (FileSystem, decoder, encode)

import Json.Decode as D
import Json.Encode as E


type FileSystem
    = FileSystem D.Value


decoder : D.Decoder FileSystem
decoder =
    D.map FileSystem D.value


encode : FileSystem -> E.Value
encode (FileSystem value) =
    value
