port module FileSystem exposing (exists, readUtf8)

import Json.Decode as D
import Json.Encode as Json
import Procedure exposing (Procedure)
import Procedure.Channel as Channel exposing (ChannelKey)



-- public API


exists : String -> Procedure String Bool msg
exists path =
    Channel.open
        (call
            { method = "exists"
            , args = [ Json.string path ]
            , postprocess = None
            }
            >> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult D.bool)


readUtf8 : String -> Procedure String String msg
readUtf8 path =
    Channel.open
        (call
            { method = "read"
            , args = [ Json.string path ]
            , postprocess = DecodeUtf8
            }
            >> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult D.string)



-- Internal


type Postprocess
    = DecodeUtf8
    | None


call : { method : String, args : List Json.Value, postprocess : Postprocess } -> ChannelKey -> Json.Value
call { method, args, postprocess } key =
    Json.object
        [ ( "key", Json.string key )
        , ( "call"
          , Json.object
                [ ( "method", Json.string method )
                , ( "args", Json.list identity args )
                ]
          )
        , ( "postprocess"
          , case postprocess of
                DecodeUtf8 ->
                    Json.string "decodeUtf8"

                None ->
                    Json.null
          )
        ]


hasSameKey : ChannelKey -> Json.Value -> Bool
hasSameKey key data =
    case D.decodeValue (D.field "key" D.string) data of
        Ok decodedKey ->
            decodedKey == key

        Err _ ->
            False


decodeResult : D.Decoder a -> Json.Value -> Procedure String a msg
decodeResult decoder data =
    case D.decodeValue (D.field "result" decoder) data of
        Ok result ->
            Procedure.provide result

        Err error ->
            case D.decodeValue (D.field "error" D.string) data of
                Ok errorMessage ->
                    Procedure.break errorMessage

                Err _ ->
                    Procedure.break (D.errorToString error)


port fsRequest : Json.Value -> Cmd msg


port fsResponse : (Json.Value -> msg) -> Sub msg
