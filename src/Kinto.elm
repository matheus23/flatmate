port module Kinto exposing (Id, RecordCommand(..), codecCommand, codecReceive, keyedWith, receive, send)

import Codec exposing (Codec)
import Json.Encode as E



-- TYPES


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


type Id
    = Id String


type CollectionId
    = CollectionItems
    | CollectionEntries
    | CollectionShops



-- HIGHER LEVEL API


send : Codec record -> Command record -> Cmd msg
send codecRecord command =
    Codec.encoder (codecCommand codecRecord) command |> kintoSend


receive : Codec record -> msg -> (Receive record -> msg) -> Sub msg
receive codecRecord onError produceMsg =
    kintoReceive
        (\value ->
            Codec.decodeValue (codecReceive codecRecord) value
                |> Result.toMaybe
                |> Maybe.map produceMsg
                |> Maybe.withDefault onError
        )



-- PORTS


port kintoSend : E.Value -> Cmd msg


port kintoReceive : (E.Value -> msg) -> Sub msg



-- CODECS


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


codecRecordWithId : Codec { title : String, id : Id }
codecRecordWithId =
    Codec.object (\title id -> { title = title, id = id })
        |> Codec.field "title" .title Codec.string
        |> Codec.field "id" .id codecId
        |> Codec.buildObject


codecId : Codec Id
codecId =
    Codec.string |> Codec.map Id unwrap


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



-- OTHER


unwrap : Id -> String
unwrap (Id id) =
    id


keyedWith : Id -> a -> ( String, a )
keyedWith (Id id) view =
    ( id, view )
