port module FileSystem exposing (exists)

import Json.Decode as D
import Json.Encode as Json
import Procedure exposing (Procedure)
import Procedure.Channel as Channel exposing (ChannelKey)



-- public API


exists : String -> Procedure D.Error Bool msg
exists path =
    Channel.open
        (\key ->
            Exists path
                |> encodeRequest key
                |> fsRequest
        )
        |> Channel.connect fsResponse
        |> Channel.filter
            (\key data ->
                case D.decodeValue (D.field "key" D.string) data of
                    Ok decodedKey ->
                        decodedKey == key

                    Err _ ->
                        False
            )
        |> Channel.acceptOne
        |> Procedure.andThen
            (\data ->
                case D.decodeValue (D.field "result" D.bool) data of
                    Ok bool ->
                        Procedure.provide bool

                    Err error ->
                        Procedure.break error
            )



-- Internal


type Request
    = Exists String


encodeRequest : ChannelKey -> Request -> Json.Value
encodeRequest key request =
    Json.object
        [ ( "key", Json.string key )
        , ( "call"
          , case request of
                Exists path ->
                    Json.object
                        [ ( "method", Json.string "exists" )
                        , ( "args", Json.list Json.string [ path ] )
                        ]
          )
        ]


port fsRequest : Json.Value -> Cmd msg


port fsResponse : (Json.Value -> msg) -> Sub msg
