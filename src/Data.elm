module Data exposing (..)

import Codec exposing (Codec)
import Http
import Json.Decode as D
import Json.Encode as E
import Time


type alias Item =
    { id : Id
    , lastModified : Time.Posix
    , name : String
    , amount : Maybe Amount
    , shop : Id
    , checked : Bool
    }


type alias Amount =
    { count : Int
    , prefix : String
    , suffix : String
    , indexInName : Int
    }


type alias KintoRequest data =
    { data : data
    }



-- OTHER TYPES


type Id
    = Id String



-- RECORD CODECS


codecItem : Codec Item
codecItem =
    Codec.object Item
        |> Codec.field "id" .id codecId
        |> Codec.field "last_modified" .lastModified codecTime
        |> Codec.field "name" .name Codec.string
        |> Codec.nullableField "amount" .amount codecAmount
        |> Codec.field "shop" .shop codecId
        |> Codec.field "checked" .checked Codec.bool
        |> Codec.buildObject


codecAmount : Codec Amount
codecAmount =
    Codec.object Amount
        |> Codec.field "count" .count Codec.int
        |> Codec.field "prefix" .prefix Codec.string
        |> Codec.field "suffix" .suffix Codec.string
        |> Codec.field "index_in_name" .indexInName Codec.int
        |> Codec.buildObject


codecKintoRequest : Codec r -> Codec (KintoRequest r)
codecKintoRequest codecData =
    Codec.object KintoRequest
        |> Codec.field "data" .data codecData
        |> Codec.buildObject



-- OTHER CODECS


codecId : Codec Id
codecId =
    Codec.string |> Codec.map Id (\(Id s) -> s)


codecTime : Codec Time.Posix
codecTime =
    Codec.int |> Codec.map Time.millisToPosix Time.posixToMillis



-- USEFUL STUFF


handleResponse : D.Decoder a -> Http.Response String -> Result Http.Error a
handleResponse decoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.GoodStatus_ _ body ->
            D.decodeString decoder body
                |> Result.mapError (D.errorToString >> Http.BadBody)
