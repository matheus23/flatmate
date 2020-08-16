port module Kinto exposing (Command(..), Id, encodeCommand, keyedWith, receive, send)

import Html.Attributes exposing (id)
import Json.Encode as E


port kintoSend : E.Value -> Cmd msg


send : Command -> Cmd msg
send =
    encodeCommand >> kintoSend


type Command
    = Add { title : String }
    | Update { title : String, id : Id }
    | FetchList
    | DeleteItem Id


encodeCommand : Command -> E.Value
encodeCommand cmd =
    case cmd of
        Add { title } ->
            E.object
                [ ( "command", E.string "add" )
                , ( "argument", E.string title )
                ]

        Update { title, id } ->
            E.object
                [ ( "command", E.string "update" )
                , ( "argument"
                  , E.object
                        [ ( "id", E.string <| unwrap id )
                        , ( "title", E.string <| title )
                        ]
                  )
                ]

        FetchList ->
            E.object
                [ ( "command", E.string "fetchList" ) ]

        DeleteItem id ->
            E.object
                [ ( "command", E.string "delete" )
                , ( "argument", E.string <| unwrap id )
                ]


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
