port module Kinto exposing (Command(..), Id, codecCommand, keyedWith, receive, send)

import Codec exposing (Codec)
import Json.Encode as E


port kintoSend : E.Value -> Cmd msg


send : Command -> Cmd msg
send command =
    kintoSend (Codec.encoder codecCommand command)


type Command
    = Add { title : String }
    | Update { title : String, id : Id }
    | FetchList
    | DeleteItem Id


codecCommand : Codec Command
codecCommand =
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
        |> Codec.variant1 "Add"
            Add
            (Codec.object (\title -> { title = title })
                |> Codec.field "title" .title Codec.string
                |> Codec.buildObject
            )
        |> Codec.variant1 "Update"
            Update
            (Codec.object (\title id -> { title = title, id = id })
                |> Codec.field "title" .title Codec.string
                |> Codec.field "id" .id codecId
                |> Codec.buildObject
            )
        |> Codec.variant0 "FetchList" FetchList
        |> Codec.variant1 "DeleteItem" DeleteItem codecId
        |> Codec.buildCustom


codecId : Codec Id
codecId =
    Codec.string |> Codec.map Id unwrap


type Id
    = Id String


unwrap : Id -> String
unwrap (Id id) =
    id


port kintoReceive : (List { title : String, id : String } -> msg) -> Sub msg


receive : (List { title : String, id : Id } -> msg) -> Sub msg
receive onMsg =
    let
        wrap { title, id } =
            { title = title, id = Id id }
    in
    kintoReceive (List.map wrap >> onMsg)


keyedWith : Id -> a -> ( String, a )
keyedWith (Id id) view =
    ( id, view )
