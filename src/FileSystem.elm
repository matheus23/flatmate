port module FileSystem exposing
    ( CID
    , exists
    , publish
    , readUtf8
    , reloadFileSystem
    , writeUtf8
    )

import Data.FileSystem as FileSystem exposing (FileSystem)
import Json.Decode as D
import Json.Encode as Json
import Procedure exposing (Procedure)
import Procedure.Channel as Channel exposing (ChannelKey)



-- public API


type alias CID =
    String


exists : FileSystem -> String -> Procedure String Bool msg
exists fs path =
    Channel.open
        (call
            { fs = fs
            , method = "exists"
            , args = [ Json.string path ]
            , preprocess = []
            , postprocess = Nothing
            }
            >> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult D.bool)


readUtf8 : FileSystem -> String -> Procedure String String msg
readUtf8 fs path =
    Channel.open
        (call
            { fs = fs
            , method = "read"
            , args = [ Json.string path ]
            , preprocess = []
            , postprocess = Just DecodeUtf8
            }
            >> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult D.string)


writeUtf8 : FileSystem -> String -> String -> Procedure String () msg
writeUtf8 fs path content =
    Channel.open
        (call
            { fs = fs
            , method = "write"
            , args = [ Json.string path, Json.string content ]
            , preprocess = [ ( 1, EncodeUtf8 ) ]
            , postprocess = Nothing
            }
            >> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult (D.succeed ()))


publish : FileSystem -> Procedure String CID msg
publish fs =
    Channel.open
        (call
            { fs = fs
            , method = "publish"
            , args = []
            , preprocess = []
            , postprocess = Nothing
            }
            >> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult D.string)


reloadFileSystem : Procedure String FileSystem msg
reloadFileSystem =
    Channel.open
        (\key ->
            reloadFs
                (Json.object
                    [ ( "key", Json.string key ) ]
                )
        )
        |> Channel.connect reloadedFs
        |> Channel.filter hasSameKey
        |> Channel.acceptOne
        |> Procedure.andThen (decodeResult FileSystem.decoder)



-- Internal


type Preprocess
    = EncodeUtf8


type Postprocess
    = DecodeUtf8


call :
    { fs : FileSystem
    , method : String
    , args : List Json.Value
    , preprocess : List ( Int, Preprocess )
    , postprocess : Maybe Postprocess
    }
    -> ChannelKey
    -> Json.Value
call { fs, method, args, postprocess, preprocess } key =
    Json.object
        [ ( "key", Json.string key )
        , ( "fs", FileSystem.encode fs )
        , ( "call"
          , Json.object
                [ ( "method", Json.string method )
                , ( "args", Json.list identity args )
                ]
          )
        , ( "preprocess"
          , preprocess
                |> Json.list
                    (\( index, process ) ->
                        Json.object
                            [ ( "index", Json.int index )
                            , ( "process"
                              , case process of
                                    EncodeUtf8 ->
                                        Json.string "encodeUtf8"
                              )
                            ]
                    )
          )
        , ( "postprocess"
          , case postprocess of
                Just DecodeUtf8 ->
                    Json.string "decodeUtf8"

                Nothing ->
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


port reloadFs : Json.Value -> Cmd msg


port reloadedFs : (Json.Value -> msg) -> Sub msg
