port module Ports exposing (..)

import Codec exposing (Codec)
import Json.Encode as E
import Time



-- COMMAND TYPES


type alias Command record =
    { collectionId : CollectionId
    , data : RecordCommand record
    }


type RecordCommand a
    = Add a
    | Update a
    | FetchList
    | DeleteItem Id


type alias Receive record =
    List record


type CollectionId
    = CollectionItems
    | CollectionEntries
    | CollectionShops



-- RECORD TYPES


type alias Item =
    { id : Id
    , lastModified : Time.Posix
    , entry : Id
    , checked : Bool
    }


type alias Entry =
    { id : Id
    , lastModified : Time.Posix
    , name : String
    , amount : Maybe Amount
    , shop : Id
    , lastEntered : Time.Posix
    , previouslyEntered : List Time.Posix
    }


type alias Amount =
    { count : Int
    , prefix : String
    , suffix : String
    , indexInName : Int
    }


type alias Shop =
    { id : Id
    , lastModified : Time.Posix
    , name : String
    , entryOrder : List Id
    }



-- OTHER TYPES


type Id
    = Id String



-- HIGHER LEVEL API


encodeSend : Codec record -> Command record -> E.Value
encodeSend codecRecord command =
    Codec.encoder (codecCommand codecRecord) command


subscribeReceive : Codec record -> msg -> (Receive record -> msg) -> Sub msg
subscribeReceive codecRecord onError produceMsg =
    receive
        (\value ->
            Codec.decodeValue (codecReceive codecRecord) value
                |> Result.toMaybe
                |> Maybe.map produceMsg
                |> Maybe.withDefault onError
        )



-- PORTS


port send : E.Value -> Cmd msg


port receive : (E.Value -> msg) -> Sub msg



-- COMMAND CODECS


codecCommand : Codec record -> Codec (Command record)
codecCommand codecRecord =
    Codec.object Command
        |> Codec.field "collectionId" .collectionId codecCollectionId
        |> Codec.field "data" .data (codecRecordCommand codecRecord)
        |> Codec.buildObject


codecRecordCommand : Codec record -> Codec (RecordCommand record)
codecRecordCommand codecRecord =
    Codec.custom
        (\add update fetchList deleteItem value ->
            case value of
                Add info ->
                    add info

                Update info ->
                    update info

                FetchList ->
                    fetchList

                DeleteItem info ->
                    deleteItem info
        )
        |> Codec.variant1 "Add" Add codecRecord
        |> Codec.variant1 "Update" Update codecRecord
        |> Codec.variant0 "FetchList" FetchList
        |> Codec.variant1 "DeleteItem" DeleteItem codecId
        |> Codec.buildCustom


codecReceive : Codec record -> Codec (List record)
codecReceive =
    Codec.list


codecCollectionId : Codec CollectionId
codecCollectionId =
    Codec.custom
        (\items entries shops value ->
            case value of
                CollectionItems ->
                    items

                CollectionEntries ->
                    entries

                CollectionShops ->
                    shops
        )
        |> Codec.variant0 "CollectionItems" CollectionItems
        |> Codec.variant0 "CollectionEntries" CollectionEntries
        |> Codec.variant0 "CollectionShops" CollectionShops
        |> Codec.buildCustom



-- RECORD CODECS


codecItem : Codec Item
codecItem =
    Codec.object Item
        |> Codec.field "id" .id codecId
        |> Codec.field "last_modified" .lastModified codecTime
        |> Codec.field "entry" .entry codecId
        |> Codec.field "checked" .checked Codec.bool
        |> Codec.buildObject


codecEntry : Codec Entry
codecEntry =
    Codec.object Entry
        |> Codec.field "id" .id codecId
        |> Codec.field "last_modified" .lastModified codecTime
        |> Codec.field "name" .name Codec.string
        |> Codec.nullableField "amount" .amount codecAmount
        |> Codec.field "shop" .shop codecId
        |> Codec.field "last_entered" .lastEntered codecTime
        |> Codec.field "previously_entered" .previouslyEntered (Codec.list codecTime)
        |> Codec.buildObject


codecShop : Codec Shop
codecShop =
    Codec.object Shop
        |> Codec.field "id" .id codecId
        |> Codec.field "last_modified" .lastModified codecTime
        |> Codec.field "name" .name Codec.string
        |> Codec.field "entry_order" .entryOrder (Codec.list codecId)
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



-- OTHER


keyedWith : Id -> a -> ( String, a )
keyedWith (Id id) view =
    ( id, view )
