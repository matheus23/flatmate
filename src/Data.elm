module Data exposing (..)

import Codec exposing (Codec)
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



-- OTHER CODECS


codecId : Codec Id
codecId =
    Codec.string |> Codec.map Id (\(Id s) -> s)


codecTime : Codec Time.Posix
codecTime =
    Codec.int |> Codec.map Time.millisToPosix Time.posixToMillis
