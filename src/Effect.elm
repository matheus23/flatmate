module Effect exposing (..)

import Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Ports


type Expect msg
    = ExpectString (Result Http.Error String -> msg)


expectJson : (Result Http.Error a -> msg) -> Decoder a -> Expect msg
expectJson msg decoder =
    ExpectString
        (Result.andThen
            (D.decodeString decoder
                >> Result.mapError (D.errorToString >> Http.BadBody)
            )
            >> msg
        )


type Body
    = EmptyBody


type Effect msg
    = None
    | SendPort E.Value
    | Http
        { url : String
        , method : String
        , body : Body
        , expect : Expect msg
        }


perform : Effect msg -> Cmd msg
perform effect =
    case effect of
        None ->
            Cmd.none

        SendPort value ->
            Ports.send value

        Http { url, method, body, expect } ->
            let
                performExpect : Expect msg -> Http.Expect msg
                performExpect e =
                    case e of
                        ExpectString m ->
                            Http.expectString m

                performBody : Body -> Http.Body
                performBody EmptyBody =
                    Http.emptyBody
            in
            Http.request
                { url = url
                , method = method
                , headers = []
                , body = performBody body
                , expect = performExpect expect
                , timeout = Nothing
                , tracker = Nothing
                }
